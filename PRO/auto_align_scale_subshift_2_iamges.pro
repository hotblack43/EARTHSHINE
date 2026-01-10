FUNCTION residuals, X
common moonres,im1_orig,im2_orig,diff
l=size(im1,/dimensions)
;
factor=x(0)
xshift=x(1) 
yshift=x(2) 
;angle=x(3)
angle=0.0
print,'P:',x
;
im1=im1_orig
im2=im2_orig
im1=shift_sub(im1*factor,xshift,yshift)
im1=ROT(im1, angle, 1.0,CUBIC=-0.5d0)
diff=(im2(10:149,*)-im1(10:149,*))/im1(10:149,*)
;err=max(abs(diff))*100.0
err=total(diff^2,/double)
;contour,diff,/cell_fill,xstyle=1,ystyle=1
print,err,mean(im1(0:149,*)),mean(im2(0:149,*))
return, err
END

common moonres,im1,im2,diff
pathname='ANDOR/'
file1=pathname+'align_stacked_BBSO-10Frame-r2.fits'
file2=pathname+'align_stacked_CoAdd-100Frame-LO-r4.fits'
im1=(readfits(file1)-2.1474837e+09)
im2=(readfits(file2)-2.1474837e+09)
xi = TRANSPOSE([[0.,1.,0.],[0.,0.,1.],[1.,0.,0.]])
;xi = TRANSPOSE([[1,0,0,0],[0.,1.,0.,0.],[0.,0.,1.,0.],[0.,0.,0.,1.0]])
xshift=5.0d0
yshift=0.0d0
angle=0.0d0
factor=2e-3
p=[factor,xshift,yshift]
;p=[factor,xshift,yshift,angle]
ftol=1.0d-9
POWELL, P, xi, ftol, fmin, 'residuals',/double,itmax=2000
print,'P=',P
contour,diff,/cell_fill,xstyle=1,ystyle=1

end
