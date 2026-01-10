PRO make_circle,x0,y0,r,x,y
angle=findgen(3000)/3000.*360.0
x=fix(x0+r*cos(angle*!dtor))
y=fix(y0+r*sin(angle*!dtor))
return
end

PRO un_pad_image,in,out
; will take an array 'in' and return the middle 9th
l=size(in,/dimensions)
xr=[l(0)/3.,l(0)*2./3.]
yr=[l(1)/3.,l(1)*2./3.]
out=in(xr(0):xr(1),yr(0):yr(1))
return
end

PRO pad_image,in,out,nx,ny
; will take an array 'in' and pad it on all sides
; with equal sized arrays so that it becomes
; the middle of 9 such arrays.
z=in*0.0d0+min(in)
top=[z,z,z]
bottom=top
middle=[z,in,z]
out=[[top],[middle],[bottom]]
l=size(out,/dimensions)
nx=l(0)
ny=l(1)
return
end

PRO get_ideal_image,ideal
 common circledats,x0,y0,radius,mask
 fname='MSO_simlated.fit'
 fname='/home/pth/SCIENCEPROJECTS/EARTHSHINE/Eshine/lib_eshine/OUTPUT/LunarImg_ideal_0055.fit'
 ideal=readfits(fname)
 ideal=ideal(0:1023,0:1023)
;ideal=ideal-110.0
;ideal(where(ideal lt 0)) = 0.0
;ideal=congrid(ideal,200,200,/center,/interp)
l=size(ideal,/dimensions)
ideal=rebin(ideal,l(0)/4,l(1)/4)
writefits,'congriddedimage.fit',ideal
; pad the image with empty space
 pad_image,ideal,ideal,nx,ny
 ; find the center and radius
 if (file_test('circle.dat') eq 1) then begin
     openr,89,'circle.dat'
     readf,89,x0,y0,radius
     close,89
     endif
 if (file_test('circle.dat') ne 1) then begin
     contour,ideal,/cell_fill,/isotropic,/zlog
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
;----------------------------------------
 ; shift center of gravity to origin
;rowssum=total(PSF,2)
;colsum=total(PSF,1)
;rr=indgen(l(0))
;x0=total(rowssum*rr)/total(rowssum)
;y0=total(colsum*rr)/total(colsum)
; PSF=shift(PSF,-round(x0),-round(y0))
;print,-round(x0),-round(y0)
;----------------------------------------
; shift Voigt_psf back to origin
 PSF=shift(PSF,-round(l(0)/2.),-round(l(1)/2.))
;----------------------------------------
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
 trialunfolded=double(fft(fft(folded,-1,/double)/fft(PSF,-1,/double),1,/double))
 ZMOD = mask*trialunfolded
 unfolded=trialunfolded
 ;window,2,title='Current deconvolved'
 sh1=folded*mask	; shows the masked 'observed' image
 ;plot,sh1(*,l(1)/2.),/ylog
 ;oplot,zmod(*,l(1)/2.),color=fsc_color('red')
 ;window,0,title='unfolded image'
 ;surface,unfolded,/zlog
 return, ZMOD
 END
 
 
 PRO go_fit_the_PSF
 common ims,ideal,PSF,folded,unfolded
 common circledats,x0,y0,radius,mask
 ; Define the starting point:
 scale=randomu(seed)*5.0d0	; starting guess for Voigt parameter
 factor=randomu(seed)*1.0d9
 start_parms = [scale,factor]
 start_parms=[4.999,  2.4617086e+08]
; Find best parameters using MPFIT2DFUN method
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
 fixed:0, limited:[0,0], limits:[0.D,0],step:1.0d-4}, 2)
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
 PRINT, 'Solution point: ', results,' +/- ',sigs
 return
 end

 PRO show_results 
 common PSFpars,pars
 common ims,ideal,PSF,folded,unfolded
 un_pad_image,ideal,ideal
 un_pad_image,folded,folded
 un_pad_image,unfolded,unfolded
 un_pad_image,PSF,PSF
 l=size(ideal,/dimensions)
openr,11,'circle.dat'
readf,11,x0,y0,r
close,11
make_circle,x0,y0,r,x,y
residuals=(ideal-unfolded*pars(1))/ideal*100.0
;bad=where(finite(residuals) ne 1)
;residuals(bad)=0.0
;residuals=smooth(residuals,3)
maxpos=where(residuals eq max(residuals))
minpos=where(residuals eq min(residuals))
nsteps=11.
minval=min(residuals(where(finite(residuals) eq 1)))
maxval=max(residuals(where(finite(residuals) eq 1)))
step=(maxval-minval)/nsteps
levels=findgen(nsteps)*step+minval
 !P.MULTI=[0,1,2]
congridded_image=readfits('congriddedimage.fit')
set_plot,'ps
device,/color
device,xsize=18,ysize=24.5,yoffset=2,filename='results.ps'
 plot,residuals(*,l(1)/2.),title='Residuals across image',ystyle=1
 contour,abs(residuals),/cell_fill,nlevels=101,/isotropic,xstyle=1,ystyle=1
 contour,abs(residuals),levels=levels,c_labels=findgen(nsteps)*0+1,title='residuals image, contours in percent',/isotropic,xstyle=1,ystyle=1,/overplot,color=255
; contour,congridded_image,/cell_fill,nlevels=101,/isotropic,xstyle=1,ystyle=1,title='Input image',/zlog
oplot,x,y,psym=3
device,/close
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
 show_results
 end
