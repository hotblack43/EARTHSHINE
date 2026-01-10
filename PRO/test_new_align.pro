PRO gofindmostcontrastregion,im,idx
 contrast=sobel(im)/im
 idx=where(contrast gt 0.2*max(contrast))
 jdx=where(contrast le 0.2*max(contrast))
 contrast(jdx)=0
 contrast(idx)=1
 tvscl,contrast
 return
 end
 
 
 stack=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456016/2456016.8795716MOON_IRCUT_AIR.fits.gz')
 niter=4
	origav=avg(stack)
	avim_0=avg(stack,2)
 for iter=0,niter,1 do begin
     print,'Iteration ',iter
     avim=avg(stack,2)
	print,'Mean of avim: ',mean(avim,/double)
	idx=where(avim gt max(avim)/100.)
	jdx=where(avim le max(avim)/100.)
	print,'mean of BS: ',mean(avim(idx))
	print,'mean of DS: ',mean(avim(jdx))
	for k=0,99,1 do begin
                 im=reform(stack(*,*,k))
	         dshifts=alignoffset(avim,im)
                 shifted=shift_sub(im,dshifts(0),dshifts(1))
                 r=correlate(avim,shifted)
	         stack(*,*,k)=shifted
		 nowavg=avg(stack)
	; stack=stack*origav/nowavg
         endfor
     endfor
        avim=avg(stack,2)
	d=avim_0-avim
	tvscl,d
 end
