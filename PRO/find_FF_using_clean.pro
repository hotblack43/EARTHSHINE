PRO get_estimated_sky_background,im,sky
print,min(im)
histo,im,1000,1900,10
sky=median(im)
return
end

PRO get_psf,im,psf
 width=21
 imax=where(im eq max(im))
 a=array_indices(im,imax)
 psf=im(a(0)-width:a(0)+width,a(1)-width:a(1)+width)
 surface,psf,title='PSF extracted from strongest source'
 return
 end
 
 bias=readfits('~/Desktop/ASTRO/halfmeanmedian20msdark.fits')
 im=readfits('stack.fits')-bias*10.0d0
 ADU=3.78	; photons/ADU 
 im=im*ADU
 get_psf,im,psf
 get_estimated_sky_background,im,sky
 maxdist=2  & display=0 & verbose=0 & cross=1
!P.MULTI=[0,1,2]
openw,66,'stats.dat'
for itry=1,100,1 do begin
surf=sfit(im,2)
surf=surf/mean(surf)
surface,rebin(surf,32,32)
 imax=where(im eq max(im))
 a=array_indices(im,imax)
 xloc=a(0)
 yloc=a(1)
iters=300	; found empirically
; Apply CLEAN algorithm
clean,im,psf,xloc,yloc,maxdist,iters,new_image,image_after_subtraction,cross=cross,DISPLAY=display,VERBOSE=verbose
;
moms=moment(image_after_subtraction/surf)
printf,66,itry,stddev(image_after_subtraction),moms(2)
print,itry,stddev(image_after_subtraction),moms(2)
surface,im,title='im'
im=image_after_subtraction
endfor
close,66
data=get_data('stats.dat')
itry=reform(data(0,*))
SD=reform(data(1,*))
skew=reform(data(2,*))
plot,itry,sd,xtitle='# of stars removed',ytitle='SD of field'
oplot,[!X.CRANGE],[sqrt(sky),sqrt(sky)],linestyle=2
plot,itry,skew,xtitle='# of stars removed',ytitle='Skewness of field/(fitted flat)'
oplot,[!X.CRANGE],[0,0],linestyle=2
 end
