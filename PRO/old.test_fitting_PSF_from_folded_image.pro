PRO get_ideal_image,ideal
common circledats,x0,y0,radius,mask
fname='MSO_simlated.fit'
ideal=readfits(fname)
ideal=ideal-110.0
ideal(where(ideal lt 0)) = 0.0
ideal=congrid(ideal,256,256)
; find the center and radius
if (file_test('circle.dat') eq 1) then begin
openr,89,'circle.dat'
readf,89,x0,y0,radius
close,89
endif
if (file_test('circle.dat') ne 1) then begin
contour,ideal,/cell_fill,/isotropic
print,'Now click on three points on the rim of the Moon'
cursor,x1,y1
wait,1
cursor,x2,y2
wait,1
cursor,x3,y3
wait,1
fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
openw,89,'circle.dat'
printf,89,x0,y0,radius
close,89
endif
; now make a mask that is 1 on the sky and 0 on the disc
l=size(ideal,/dimensions)
Nx=l(0)
Ny=l(1)
XR = indgen(Nx)
YC = indgen(Ny)
X = double(XR # (YC*0 + 1))        ;     eqn. 1
Y = double((XR*0 + 1) # YC)        ;     eqn. 2
r=sqrt((x-l(0)/2.)^2+(y-l(1)/2.)^2)
mask=ideal*0.0
idx=where(r gt radius)
mask(idx)=1.0
return
end

PRO get_PSF,PSF,l
common PSFpars,pars
PSF=dblarr(l(0),l(1))
Nx=l(0)
Ny=l(1)
XR = indgen(Nx)
YC = indgen(Ny)
X = double(XR # (YC*0 + 1))        ;     eqn. 1
Y = double((XR*0 + 1) # YC)        ;     eqn. 2
r=sqrt((x-l(0)/2.)^2+(y-l(1)/2.)^2)
PSF=voigt(pars(0),r)
; shift Voigt_psf back to origin
PSF=shift(PSF,l(0)/2.,l(1)/2.)
PSF=PSF*pars(1)
return
end

PRO go_fold_image_with_PSF
common ims,ideal,PSF,folded,unfolded
folded=fft(fft(ideal,-1,/double)*fft(PSF,-1,/double),1,/double)
folded=double(folded)
return
end

FUNCTION minimize_me, X, Y, P
common ims,ideal,PSF,folded,unfolded
common PSFpars,pars
common circledats,x0,y0,radius,mask
     ; The independent variables are X and Y
pars=p
l=size(ideal,/dimensions)
get_PSF,PSF,l
     ; Parameter values are passed in "P"
trialunfolded=double(fft(fft(folded,-1)/fft(PSF,-1),1))
ZMOD = mask*trialunfolded
print,total(zmod)/l(0)/l(1)
window,2,title='Current deconvolved'
plot,zmod(*,l(1)/2.)
unfolded=trialunfolded
window,0,title='unfolded image'
surface,unfolded,/zlog
return, ZMOD
END


PRO go_fit_the_PSF
common ims,ideal,PSF,folded,unfolded
common circledats,x0,y0,radius,mask
 ; Define the starting point:
scale=randomu(seed)*5.0d0	; starting guess for Voigt parameter
factor=randomu(seed)*1.0d0
start_parms = [5.1,1.1]
start_parms = [scale,factor]
; Find best parametrs using MPFIT2DFUN method
l=size(ideal,/dimensions)
Nx=l(0)
Ny=l(1)
XR = indgen(Nx)
YC = indgen(Ny)
X = double(XR # (YC*0 + 1))        ;     eqn. 1
Y = double((XR*0 + 1) # YC)        ;     eqn. 2
;err=sqrt(folded>1) ; Poisson noise ...
err=folded*0.0+1.0
z=ideal*0.0	; target is a zero plane
 ; set up the PARINFO array - indicate double-sided derivatives (best)
 parinfo = replicate({mpside:2, value:0.D, $
 fixed:0, limited:[0,0], limits:[0.D,0],step:1.0d-2}, 2)
parinfo[0].fixed = 0
parinfo[1].fixed = 0
; Voigt profile width
parinfo[0].limited(0) = 1
parinfo[0].limits(0)  = 0.0
parinfo[0].limited(1) = 1
parinfo[0].limits(1)  = 100.
; factor on profile
parinfo[1].limited(0) = 1
parinfo[1].limits(0)  = 0.0
parinfo[1].limited(1) = 0
parinfo[1].limits(1)  = 0
parinfo[*].value = start_parms
 ; print,parinfo
 results = MPFIT2DFUN('minimize_me', X, Y, Z, ERR, $
 PARINFO=parinfo,perror=sigs,STATUS=hej,xtol=1e-15)
 ; Print the solution point:
 print,'STATUS=',hej
 PRINT, 'Solution point: ', results
return
end


;============================================================================
; Code to test whether it is possible to find the PSF in a folded image by
; guessing at the properties of the PSF and deconvolving the 'observed' image
;-----------------------------------------------------
common PSFpars,pars
common ims,ideal,PSF,folded,unfolded
;-----------------------------------------------------
; get the ideal input image
get_ideal_image,ideal
l=size(ideal,/dimensions)
; get the PSF, passing PSF parameters via common block
pars=[5.0,1.0]
get_PSF,PSF,l
; fold the ideal image with the PSF, making the 'observed image'
go_fold_image_with_PSF
; try to fit your way to the parameters of the PSF actually used
go_fit_the_PSF
end
