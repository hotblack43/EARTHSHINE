FUNCTION flipimage,im,direction
l=size(im,/dimensions)
ncols=l(0)
nrows=l(1)
if (direction eq 1) then begin
print,'Flipping horizontally'
; want flip about horizontal axis
dummy=dblarr(ncols)
for irow=0,(nrows-1)/2 do begin
    dummy(*)=im(*,irow)
    im(*,irow)=im(*,nrows-1-irow)
    im(*,nrows-1-irow)=dummy(*)
endfor
endif
return,im
end

path='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\'
im1=readfits(path+'Moon_simulated_1.FIT')
l=size(im1,/dimensions)

path='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\DATA\'
im2=readfits(path+'moon20060731.00000343.FIT')
nits=1
im1_scaling=0.299
Angle=-24.

im1_use=im1

im1_use=flipimage(im1_use,1)
im1_use = ROT( im1_use, Angle,/INTERP, CUBIC=-0.5)
im1_use =congrid(im1_use,l(0)*im1_scaling,l(1)*im1_scaling)/4.
l=size(im1_use,/dimensions)
window,0,xsize=l(0),ysize=l(1)
tvscl,im1_use
window,1,xsize=l(0),ysize=l(1)
xshift=91
yshift=28.5
im2_use=im2(xshift:xshift+l(0)-1,yshift:yshift+l(1)-1)
tvscl,im2_use
window,2,xsize=l(0),ysize=l(1)

ratio=im2_use/im1_use
idx=where(abs(ratio) eq abs(max(ratio)))
ratio(idx)=median(ratio)
idx=where(abs(ratio) eq abs(min(ratio)))
ratio(idx)=median(ratio)
idx=where(abs(ratio) eq abs(max(ratio)))
ratio(idx)=median(ratio)
tvscl,ratio
writefits,'Image_1.fit',im1_use
writefits,'Image_2.fit',im2_use
write_jpeg,'Image_1.jpg',im1_use
write_jpeg,'Image_2.jpg',im2_use
end