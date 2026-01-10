;---------------------------------------------------------------------------
; Code that fits an ideal lunar image to a real image, convolving with a
; grid-searcehd set of PSF.
;---------------------------------------------------------------------------
; The error to minimize is evaluated on the sky between ceratin columns.
; Since the ideal image only includes the BS what remains after subtraction 
; of the best fitting model is the 'cleaned-up DS'. Only use the cleaned-up 
;---------------------------------------------------------------------------
mask=readfits('mask.fits')	;	512x512 (allows only sky pixels)
observed=readfits('presentinput.fits')	; 512x512
ideal=readfits('ideal.fits')	; 1536x1536
PSForig=readfits('PSF_fromHalo_1536.fits')	; 1536x1536
;........................
idealFFT=fft(ideal,-1)
l=float(size(ideal,/dimensions))
area=float(l(0)*l(1))
nsteps=20
alfamin=1.3
alfamax=1.8
error=fltarr(nsteps)
alfas=findgen(nsteps)/float(nsteps)*(alfamax-alfamin)+alfamin
a=92	; a and b are lefta nd right columnslimits for error evaluation
b=250	
a=0
b=511
errmin=1e33
;........................
for i=0,nsteps-1,1 do begin
alfa=alfas(i)
PSF=PSForig^alfa
PSF=PSF/total(PSF,/double)*area
convolved=float((fft(idealFFT*fft(PSF,-1),1)))
subim=convolved(512:2*512-1,512:2*512-1)
errim=mask*(subim-observed)
plot,errim(a:b,256)
err=total(errim(a:b,*)^2)
error(i)=err
print,i,alfa,err
if (err lt errmin) then begin
errmin=err
bestmodel=subim
endif
endfor
idx=where(error eq min(error))
print,'Smallest error is:',error(idx),' at alfa=',alfas(idx)
writefits,'bestmodel.fits',bestmodel
end
