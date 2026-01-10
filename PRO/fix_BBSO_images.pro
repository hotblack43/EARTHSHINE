file='earthshine_BBSO_crescent.fit'
im1=readfits(file)
im2=total(im1,3)
writefits,'earthshine_BBSO_crescent_coadded.fit',double(im2)
;surface,im2
file='BBSOfiltered.fit'
im1=readfits(file)
im3=total(im1,3)
writefits,'BBSOfiltered_coadded.fit',double(im3)
;surface,im3
 im4=im2*150.+im3 - 1000.; combine into one fake BBSO image
 idx=where(im4 lt 0.)
 im4(idx)=50.0
 l=size(im4,/dimensions)
 writefits,'fake_BBSO.fit',double(im4(0:l(0)-1-3,0:l(1)-1))
 im4=readfits('fake_BBSO.fit')
 contour,alog(im4),/cell_fill,nlevels=101,/isotropic
plot,im4(*,5)
end
