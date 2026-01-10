PRO blankout,image,x0,y0,radius
l=size(image,/dimensions)
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
dist2=((i-x0)^2+(j-y0)^2)
if (dist2 lt radius*radius) then image(i,j)=0.0
endfor
endfor
return
end

PRO make_im_odd_dimensioned,im
; will make the number of rows and columns odd if they are not already
l=size(im,/dimensions)
if (fix(l(0)/2.) eq l(0)/2.) then begin
; the number of columns is even
im=im(0:l(0)-1-1,*)
endif
if (fix(l(1)/2.) eq l(1)/2.) then begin
; the number of rows is even
im=im(*,0:l(1)-1-1)
endif
return
end

PRO make_psf,im,psf
psf=im*0.0
l=size(im,/dimensions)
middle_col=fix(l(0)/2.)
middle_row=fix(l(1)/2.)
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
dist2=((double(i-middle_col))^2+(double(j-middle_row))^2)
if (dist2 ne 0.0) then psf(i,j)=1.d0/dist2
endfor
endfor
; shift the middle to the corner
psf=shift(psf,middle_col,middle_row)
return
end

file='stacked_new_349_float.FIT'
im=readfits(file)
; first make sure im has odd numbers of rows and columns
make_im_odd_dimensioned,im
; then construct the PSF
make_psf,im,psf
; set up the 'mother image'
limit=0.9	; this is the cutoff to generate the Mother image from the real image
idx=where(im gt limit*max(im))
im_orig=im*0.0
im_orig(idx)=im(idx)
; now generate the scattered image from the mother image by convolution
scattered_im=fft(fft(psf,-1)*fft(im_orig,-1),1)
; plots
plot_io,total(im,2),charsize=2,xtitle='Columns number',ytitle='Row sum of pixels',title='Original image'
plot_io,total(im_orig,2),charsize=2,xtitle='Columns number',ytitle='Row sum of pixels',title='Mother image',yrange=[1e3,1e7]
plot_io,total(scattered_im,2),charsize=2,xtitle='Columns number',ytitle='Row sum of pixels',title='Model of scattered light image',yrange=[0.1,1000]
; blankout centre of both original image and scattered_im
radius=110.0
x0=176.1
y0=260.2
blankout,im,x0,y0,radius
!P.MULTI=[0,2,2]
;device,decomposed=0
loadct,11
contour,bytscl(im),title='Original image, blanked',/cell_fill,nlevels=256
blankout,scattered_im,x0,y0,radius
factor=6000.
rest=im-factor*scattered_im
contour,bytscl(factor*scattered_im),title='scattered light model, blanked',/cell_fill,nlevels=256
contour,bytscl(rest),title='residual',/cell_fill,nlevels=256
plot,rest(*,y0),title='Row sum of residual,  across centre',yrange=[-20,30]
end
