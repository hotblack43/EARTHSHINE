FUNCTION get_mean_flux_in_box,im
xl=283
xr=309
yd=309
yu=326
subim=im(xl:xr,yd:yu)
idx=where(finite(subim) eq 1)
res=mean(subim(idx))
return,res
end



;----------------------------------------------------
; version 1 of Full Forward Method
; a,b and alfa are looped over
;----------------------------------------------------
; get the observed image
observed=readfits('synth_observed_1p7.fits')+0.01
obsBOX=get_mean_flux_in_box(observed)
; get the ideal image for time of observation
ideal=readfits('ideal_in.fits')
idealBOX=get_mean_flux_in_box(ideal)
openw,33,'FFM.results'
; select trial values of the parameters
for alfa=1.6,2.0,0.01 do begin
; go and convolve the ideal image with PSF(alfa)
str='./justconvolve ideal_in.fits ideal_folded_out.fits '+string(alfa)
print,'Spawning this: ',str
spawn,str
; scale and offset
dummy=readfits('ideal_folded_out.fits')
for a=-0.02,0.01,0.005 do begin
for b=0.98,1.02,0.005 do begin
trial_image=a+b*dummy
trialBOX=get_mean_flux_in_box(trial_image)
; calculatethe residuals
residual=(trial_image-observed)/observed*100.0
residualBOX=get_mean_flux_in_box(residual)
;
residual2=(a+b*ideal-ideal)/ideal*100.0
residual2BOX=get_mean_flux_in_box(residual2)
; print out some results
fmt='(3(1x,f9.3),1x,g12.1,2(1x,f9.3))'
printf,33,format=fmt,alfa,a,b,999.999,residualBOX,residual2BOX
print,format=fmt,alfa,a,b,999.999,residualBOX,residual2BOX
endfor
endfor
endfor
close,33
end
