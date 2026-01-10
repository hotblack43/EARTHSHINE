PRO determineoffsetfactor,im,blurred,factor,offset
 ; work out the factor and offset to ensure match on sky and tip
 ;fittop=120 ; middle of force-fit patch in x
 ;colwhere=(ro1+ro2)/2.  ; middle of force-fit patch in y
 ; Find the place in the image where the maximum (smoothed) intensity is
 ; and set up the 'force-fit patches' there.
 idx=where(smooth(im,3) eq max(smooth(im,3)))
 coo=array_indices(im,idx)
 fittop=coo(0)
 fitsky=95; middle of sky force-fit patch in x - user set!
 colwhere=coo(1)
 wid=2  ; width of patch to force image to fit in
;...............
factor=mean((im(fittop-wid:fittop+wid,colwhere-wid:colwhere+wid)-im(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid))/(blurred(fittop-wid:fittop+wid,colwhere-wid:colwhere+wid)-blurred(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid)))
;...............
offset=mean(im(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid)-blurred(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid)*factor)
;...............
;print,'offset and factor: ',offset,factor
return
end

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
nsteps=40
alfamin=1.5
alfamax=1.9
error=fltarr(nsteps)
alfas=findgen(nsteps)/float(nsteps)*(alfamax-alfamin)+alfamin
a=92	; a and b are lefta nd right columnslimits for error evaluation
b=250	
a=90
b=511
errmin=1e33
;........................
for i=0,nsteps-1,1 do begin
alfa=alfas(i)
PSF=PSForig^alfa
PSF=PSF/total(PSF,/double)*area
convolved=float((fft(idealFFT*fft(PSF,-1),1)))
; determine factor and offset
subim=convolved(512:2*512-1,512:2*512-1)
determineoffsetfactor,observed,subim,factor,offset
subim=subim*factor+offset
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
writefits,'bestdifference.fits',observed-bestmodel
end
