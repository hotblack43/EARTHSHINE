FUNCTION get_mean_flux_in_box,im
xl=283
xr=309
yd=309
yu=326
subim=im(xl:xr,yd:yu)
idx=where(finite(subim) eq 1)
res=sqrt(mean(subim(idx)^2))
return,res
end



;----------------------------------------------------
; version 2 of Full Forward Method
; a and alfa are looped over, b is calculated from flux
; normalization
;----------------------------------------------------
; get the observed image
observed=readfits('synth_observed_1p6.fits')+0.01
l=size(observed,/dimensions) & n=l(0)
obsBOX=get_mean_flux_in_box(observed)
; get the ideal image for time of observation
ideal=readfits('ideal_in.fits')
idealBOX=get_mean_flux_in_box(ideal)
openw,33,'FFM.results'
; select trial values of the parameters
for alfa=1.5,1.9,0.005 do begin
; go and convolve the ideal image with PSF(alfa)
str='./justconvolve ideal_in.fits ideal_folded_out.fits '+string(alfa)
spawn,str
; scale and offset
dummy=readfits('ideal_folded_out.fits')
for a=-0.05,0.05,0.005 do begin
; find the scaling constant
b=(total(observed,/double)-a*float(n)*float(n))/total(dummy,/double)
trial_image=a+b*dummy
trialBOX=get_mean_flux_in_box(trial_image)
; calculate the residuals obtainable from the observed image and the trialimage
residual=(trial_image-observed)/trial_image*100.0
residualBOX=get_mean_flux_in_box(residual)
; calculate the residual obtainable from the
residual2=(a+b*ideal-ideal)/ideal*100.0
residual2BOX=get_mean_flux_in_box(residual2)
; print out some results
fmt='(3(1x,f9.5),1x,g12.1,2(1x,f12.6))'
printf,33,format=fmt,alfa,a,b,999.999,residualBOX,residual2BOX
print,format=fmt,alfa,a,b,999.999,residualBOX,residual2BOX
endfor
endfor
close,33
end
