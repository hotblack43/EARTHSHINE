file1='meanim_Moon_SKE.fits'
file2='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455641/LunarImg_0000.fit'
;
im1=readfits(file1)
im1=im1/mean(im1(300:310,300:310))
im2=readfits(file2)
im2=reverse(rotate(im2,2))
im2=im2/mean(im2(300:310,300:310))
manual_align,im2,im1,offset,diff
print,'offset: ',offset
end
