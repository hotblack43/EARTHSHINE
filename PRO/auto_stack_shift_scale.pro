FUNCTION moonresidual_4pars,parameters
common ims,newlens,oldlens,residuals,try
common fixed_stuff,fixed_scale
print,'Parameters tried:',parameters
hs=parameters(0)
vs=parameters(1)
factor=parameters(2)
angle=parameters(3)
; perhaps apply sobel filter
;newlens_=sobel(newlens)
;oldlens_=sobel(oldlens)
newlens_=newlens
oldlens_=oldlens
;
try=newlens_
ratio=try/oldlens_
try=shift_sub(newlens_,hs,vs)
try=ROT(try,angle,fixed_scale,CUBIC=-0.5)
try=try*factor
residuals=(try-oldlens_)/oldlens_*100.0
window,2,xsize=512,ysize=512
tvscl,residuals
subim1=residuals(203:266,90:418)
subim2=residuals(287:424,189:313)
l1=size(subim1,/dimensions)
l2=size(subim2,/dimensions)
window,1,xsize=400,ysize=650
!P.MULTI=[0,1,2]
plot,total(subim1,2)/l1(1)
plot,total(subim2,2)/l2(1)
err4=total(subim1^4+subim2^4,/double)
err2=total(subim1^2+subim2^2,/double)
err=err4	; ^4 in order to push down spikes
print,'Error^4=',err4
print,'Error^2=',err2
RETURN, err
END

FUNCTION moonresidual_5pars,parameters
common ims,newlens,oldlens,residuals,try
print,'Parameters tried:',parameters
hs=parameters(0)
vs=parameters(1)
scale=parameters(2)
factor=parameters(3)
angle=parameters(4)
; perhaps apply sobel filter
;newlens_=sobel(newlens)
;oldlens_=sobel(oldlens)
newlens_=newlens
oldlens_=oldlens
;
try=newlens_
ratio=try/oldlens_
try=shift_sub(newlens_,hs,vs)
try=ROT(try,angle,scale,CUBIC=-0.5)
try=try*factor
residuals=(try-oldlens_)/oldlens_*100.0
window,2,xsize=512,ysize=512
tvscl,residuals
subim1=residuals(203:266,90:418)
subim2=residuals(287:424,189:313)
l1=size(subim1,/dimensions)
l2=size(subim2,/dimensions)
window,1,xsize=400,ysize=650
!P.MULTI=[0,1,2]
plot,total(subim1,2)/l1(1)
plot,total(subim2,2)/l2(1)
err4=total(subim1^4+subim2^4,/double)
err2=total(subim1^2+subim2^2,/double)
err=err4	; ^4 in order to push down spikes
; special - whole disc
err=total(residuals^4,/double)
print,'Error^4=',err4
print,'Error^2=',err2
RETURN, err
END

common ims,newlens,oldlens,residuals,try
common fixed_stuff,fixed_scale
newlens=readfits('stacked_r1-1_new_lens_100_float.FIT')
oldlens=readfits('stacked_R1-1_old_lens_100_float.FIT')
npars=5
if (npars eq 4) then begin
; Do fitting for 4 parameters
; start guess for parameters
hs=5.5800275
vs=-7.4344053
fixed_scale=1.0025d0
factor=0.88857707
angle=0.26050415
P=[hs,vs,factor,angle]
if (file_test('POWELL_pars_4pars') eq 1) then p=get_data('POWELL_pars_4pars')
 ; Define the starting directional vectors in column format:
 xi = TRANSPOSE([[1.,0.,0.,0.],[0.,1.,0.,0.],[0.,0.,1.,0.],[0.,0.,0.,1.]])
Ftol=1d-9
POWELL, P, Xi, Ftol, Fmin, 'moonresidual_4pars', /DOUBLE 
print,'POWELL done, pars found = ',p
openw,4,'POWELL_pars_4pars' & printf,4,p & close,5
writefits,'ratio_shifted_scaled.fits',residuals
writefits,'try.fits',try
endif

if (npars eq 5) then begin
; Do fitting for 5 parameters
; start guess for parameters
hs=6.1880747d0
vs=-7.9090895d0
scale=1.0248584d0
factor=1.1241018d0
angle=0.3d0
P=[hs,vs,scale,factor,angle]
if (file_test('POWELL_pars_5pars') eq 1) then p=get_data('POWELL_pars_5pars')
 ; Define the starting directional vectors in column format:
 xi = TRANSPOSE([[1.,0.,0.,0.,0.],[0.,1.,0.,0.,0.],[0.,0.,1.,0.,0.],[0.,0.,0.,1.,0.],[0.,0.,0.,0.,1.]])
Ftol=1d-9
POWELL, P, Xi, Ftol, Fmin, 'moonresidual_5pars', /DOUBLE 
print,'POWELL done, pars found = ',p
openw,4,'POWELL_pars_5pars' & printf,4,p & close,5
writefits,'ratio_shifted_scaled.fits',residuals
writefits,'try.fits',try
endif
end
