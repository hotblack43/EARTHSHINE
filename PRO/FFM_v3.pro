FUNCTION get_errorINwholeIMAGE,im
idx=where(finite(im) eq 1)
; RMSE
res=sqrt(mean(im(idx)^2))
return,res
end

FUNCTION get_mean_flux_in_box,im
xl=283
xr=309
yd=309
yu=326
subim=im(xl:xr,yd:yu)
idx=where(finite(subim) eq 1)
; RMSE
res=sqrt(mean(subim(idx)^2))
; abs mean error
;res=abs(mean(subim(idx)))
return,res
end

FUNCTION petersfunc2,par
common ims,observed,trialim,idealused,ideal
common errs,functionvalue,residual2BOX
l=size(observed,/dimensions) & n=l(0)
a=par(0)
alfa=par(1)
;b=par(2)
str='./justconvolve ideal_in.fits ideal_folded_out.fits '+string(alfa)
spawn,str
ideal_folded=readfits('ideal_folded_out.fits',/silent)
b=(total(observed,/double)-a*float(n)*float(n))/total(ideal_folded,/double)
trialim=a+b*ideal_folded
residual=(observed-trialim)/observed*100.0
; evaluate model fit in a box
functionvalue=get_mean_flux_in_box(residual)
; or on whole image
functionvalue=get_errorINwholeIMAGE(residual)
; get ideal error inside BOX
residual2=((b*ideal)-idealused)/idealused*100.0
residual2BOX=get_mean_flux_in_box(residual2)
; print out some results
print,'----------------->',par,functionvalue,residual2BOX
; plot some curves
!P.MULTI=[0,1,4]
plot_io,ytitle='Observed and Trial observed',xstyle=3,observed(*,256),thick=2,color=fsc_color('red'),yrange=[1,1e5]
oplot,trialim(*,256)
plot,xstyle=3,ytitle='Rel. Diff Observed and Trial observed',$
ystyle=3,(observed(*,256)-trialim(*,256))/observed(*,256)*100.0,$
thick=2,color=fsc_color('blue')
;
plot_io,ytitle='Ideal and Trial ideal',xstyle=3,idealused(*,256),thick=2,color=fsc_color('red'),yrange=[1,1e5]
oplot,b*ideal(*,256),thick=1
;oplot,a+b*ideal(*,256),thick=1
plot,xstyle=3,yrange=[-2,2],(idealused(*,256)-(b*ideal(*,256)))/idealused(*,256)*100.0,thick=2,color=fsc_color('blue'),psym=7
;plot,xstyle=3,yrange=[-2,2],(ideal(*,256)-(a+b*ideal(*,256)))/ideal(*,256)*100.0,thick=2,color=fsc_color('blue'),psym=7
plots,[!X.crange],[0,0],linestyle=2
;
return,functionvalue
end



;----------------------------------------------------
; version 3 of Full Forward Method
; Finds a and alfa by POWELL method, b is calculated from that
;----------------------------------------------------
!P.CHARSIZE=2
common ims,observed,trialim,idealused,ideal
common errs,functionvalue,residual2BOX
; define some real-world effects
factor=3.78
pedestal=400.0
; generate a synthetic observed image
ideal=readfits('ideal_in.fits')
idealused=ideal*factor
writefits,'usethisidealimage.fits',idealused
spawn,'./syntheticmoon usethisidealimage.fits synth_observed_1p6.fits 1.6 1'
spawn,'./syntheticmoon usethisidealimage.fits synth_observed_1p7.fits 1.7 1'
spawn,'./syntheticmoon usethisidealimage.fits synth_observed_1p8.fits 1.8 1'
; get the observed image
observed=readfits('synth_observed_1p6.fits',/silent)+pedestal
;observed=readfits('synth_observed_1p7.fits',/silent)+pedestal
;observed=readfits('synth_observed_1p8.fits',/silent)+pedestal
l=size(observed,/dimensions) & n=l(0)
obsBOX=get_mean_flux_in_box(observed)
; get the ideal image for time of observation
ideal=readfits('ideal_in.fits',/silent)
idealBOX=get_mean_flux_in_box(ideal)
; select starting values of the parameters
a=mean(observed(0:20,0:20))	; base starting guess on corner value
alfa=1.6
par=[a,alfa]
;par=[a,alfa,b]
xi=[[0,1],[1,0]]
;xi=[[0,0,1],[0,1,0],[1,0,0]]
ftol=1.e-6
POWELL,par,xi,ftol,fmin,'petersfunc2'
print,'Done. pars: ',par
print,'ftol,fmin:',ftol,fmin
a=par(0)
alfa=par(1)
; print out some results
fmt='(2(1x,f9.5),1x,g12.1,2(1x,f12.6))'
print,format=fmt,alfa,a,999.999,functionvalue,residual2BOX
end
