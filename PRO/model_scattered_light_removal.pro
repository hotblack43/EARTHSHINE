PRO get_image,path,filname,im
im=readfits(path+filname,header)
idx=where(im lt 0)
im(idx)=0.0
return
end

PRO add_scattered_light,imin,imout
; convolve imin with a Gaussian PSF
radius2=IMIN*0.0
l=SIZE(radius2,/DIMENSIONS)
imin(l(0)/2.,l(1)/2.)=100.
scale=550.0
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
radius2(i,j)=((i-l(0)/2.)^2+(j-(l(1)/2.))^2)
endfor
endfor
psf=exp(-radius2/scale)
psf=psf/total(psf)
;surface,psf

imout = imin+ 1.*convolve( imin, psf )

return
end




get_image,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\','Image_1.fit',original_image
l=size(original_image,/dimensions)
window,0,xsize=l(0),ysize=l(1)
contour,alog10(original_image)
im_copy=original_image
window,1,xsize=l(0),ysize=l(1)
print,min(im_copy),max(im_copy)
histo,alog10(im_copy),1.3,1.6,.01
add_scattered_light,im_copy,im_plus_scattered
window,2,xsize=l(0),ysize=l(1)
contour,alog10(im_plus_scattered)
window,3,xsize=l(0),ysize=l(1)
histo,alog10(im_copy),0.3,1.6,.01
end