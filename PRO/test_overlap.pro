

FUNCTION overlap,pars
common images,im1,im2
l=size(im1,/dimensions)
dx=pars(0)
dy=pars(1)
;print,dx,dy
if (dx ge 0 and dy ge 0) then begin
l1=dx
r1=l(0)-1
d1=dy
u1=l(1)-1
l2=0
r2=l(0)-dx-1
d2=0
u2=l(1)-dy-1
endif
if (dx lt 0 and dy ge 0) then begin
l1=0
r1=l(0)-abs(dx)-1
d1=l(1)-dy-1
u1=l(1)-1
l2=l(0)-abs(dx)-1
r2=l(0)-1
d2=0
u2=l(1)-dy-1
endif
if (dx lt 0 and dy lt 0) then begin
l1=0
r1=l(0)-abs(dx)-1
d1=0
u1=l(1)-abs(dy)-1
l2=l(0)-1-abs(dx)
r2=l(0)-1
d2=l(1)-1-abs(dy)
u2=l(1)-1
endif
if (dx ge 0 and dy lt 0) then begin
l1=l(0)-dx-1
r1=l(0)-1
d1=0
u1=l(1)-abs(dy)-1
l2=0
r2=l(0)-dx-1
d2=l(1)-abs(dy)-1
u2=l(1)-1
endif
;print,'1: ',l1,r1,d1,u1
;print,'2: ',l2,r2,d2,u2
subim1=im1(l1:r1,d1:u1)
subim2=im1(l2:r2,d2:u2)
R=correlate(subim1,subim2)
help,subim1,subim2
error=1./R^2
;print,'Error: ',error
return,error
end


common images,im1,im2
im1=readfits('usethisidealimage.fits')
im2=readfits('usethisidealimage.fits')
; Define the starting directional vectors in column format:
pars=randomn(seed,2)*10.
xi = TRANSPOSE([[1.,0.],[0.,1.]])
; Minimize the function:
ftol=1e-8
POWELL, pars, xi, ftol, fmin, 'overlap',/double
print,'Solution: ',pars
print,'fmin: ',fmin
end
