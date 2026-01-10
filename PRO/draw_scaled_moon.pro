file='MSO_simlated.fit'
im=double(readfits(file))-110.0d0
idx=where(im lt 0)
im(idx)=0.0d0
mask=im*0.0d0+1.0d0
mask(0:201,*)=9.0d3
surface,im*mask
contour,bytscl(im*mask),/cell_fill,levels=indgen(255),/isotropic,xstyle=1,ystyle=1,title='DMI lunar simulator image'
write_jpeg,'im.jpg',bytscl(im*mask)
end
