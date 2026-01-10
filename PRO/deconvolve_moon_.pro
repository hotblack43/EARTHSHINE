PRO get_psf,im,psf,scale2
psf=im*0.0
radius2=psf*0.0
l=size(psf,/dimensions)
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
radius2(i,j)=((i-l(0))^2+(j-l(1))^2)
endfor
endfor
psf=exp(-radius2/scale2)
psf=shift(psf,l(0)/2,l(1)/2)
psf=psf/total(psf)
return
end

;======================== MAIN =============================================
file='/data/pth/DATA/moon/ANDREW/DATA/moon20060731.00000162.FIT'
im_orig=float(readfits(file))
scale2=200.
get_psf,im_orig,psf,scale2
deconv_tool, image_deconv, deconv_info, IMAGE_OBS=im_orig, PSF_OBS=psf, /TV,/MENU
;
end
