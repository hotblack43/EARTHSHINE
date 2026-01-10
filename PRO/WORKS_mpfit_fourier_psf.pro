   FUNCTION EVALUATE_PSF,  P
   common c_image,c_image,n
   common errors,err_on_disc,err_off_disc
   common masks,mask,inverse_mask,n_mask,n_invmask
common folded,folded
common linfit,res,pp,meandiff,maxabsres
common merit,merit
     ; Parameter values are passed in "P"
a=p(0)
b=p(1)
c=p(2)
a0=p(3)
; build  a trial PSF
build_psf,a0,a,b,c,n,psfnew
reformed=double(fft(fft(folded,-1,/double)/fft(psfnew,-1,/double),1,/double))

diff=folded-reformed

report_error,diff,mask,inverse_mask,n_mask,n_invmask

print,200.*res(1)^2,total(maxabsres)^2/20.,meandiff^2/10.
merit=200.*res(1)^2+total(maxabsres)^2/20.+meandiff^2/10.
return,merit
END

PRO setupsupportforlunardisc2,c_image,mask
common circle,x0,y0,radius,radius_surface
l=size(c_image,/dimensions)
if (file_test('moon_circle_data.dat') ne 1) then begin
contour,c_image
cursor,x1,y1
wait,0.2
cursor,x2,y2
wait,0.2
cursor,x3,y3
wait,0.2
openw,45,'moon_circle_data.dat'
printf,45,x1,y1
printf,45,x2,y2
printf,45,x3,y3
close,45
endif else begin
openr,45,'moon_circle_data.dat'
readf,45,x1,y1
readf,45,x2,y2
readf,45,x3,y3
close,45
endelse
fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
maxval=max(c_image)
get_circle,l,[x0,y0],circle,radius,maxval
get_mask,x0,y0,radius,mask
n=l(0)
 x=indgen(N) # replicate(1,N)
 y=replicate(1,N) # indgen(N)
 radius_surface=sqrt((x-x0)^2+(y-y0) ^2)
return
end

PRO report_error,diff,mask,inverse_mask,n_mask,n_invmask
common circle,x0,y0,radius,radius_surface
common errors,err_on_disc,err_off_disc
common linfit,res,pp,meandiff,maxabsres
common merit,merit
l=size(diff,/dimensions)
;surface,diff ,charsize=2
print,'Multiplicative deconvolution:',sqrt(total(diff^2)),' RSE'
err_on_disc=sqrt(total((diff*mask)^2)/n_mask^2)
err_off_disc=sqrt(total((diff*inverse_mask)^2)/n_invmask^2)
print,'RSE per pixel on disc:',err_on_disc
print,'RSE per pixel off-disc:',err_off_disc
;print,'ratio ON/OFF',err_on_disc/err_off_disc
; annuli
rstep=1.0
i=0
n=l(0)
 xx=indgen(N) # replicate(1,N)
 yy=replicate(1,N) # indgen(N)
for r=radius,radius*1.9,rstep do begin
idx=where(radius_surface gt r and radius_surface le r+rstep and xx gt x0,count)
if (count gt 2) then begin
if (i eq 0) then begin
	x=r+rstep/2.
	y=mean(diff(idx))
	z=stddev(diff(idx))/sqrt(count-1)
endif else begin
	x=[x,r+rstep/2.]
	y=[y,mean(diff(idx))]
	z=[z,stddev(diff(idx))/sqrt(count-1)]
endelse
i=i+1
endif
endfor
res=linfit(x,y,/double,yfit=yhat,sigma=sigs,prob=pp)
;res=linfit(x,y,measure_errors=z,/double,yfit=yhat,sigma=sigs,prob=pp)
plot,x,y,charsize=2,xtitle='Radial distance from disc centre',title='Merit: '+string(merit),ytitle='Residual'
oploterr,x,y,z
meandiff=mean(yhat)
maxabsres=max(abs(y-yhat))
oplot,x,yhat,thick=2
;print,'Slope:',res(1),' Z: ',res(1)/sigs(1)
return
end

PRO build_psf,a0,a,b,c,n,psf
common xy,x,y,r
 psf=a/(b+r^c)
 idx=where(r le 1.*min(r))
 psf(idx)=a0
 psf=psf/total(psf,/double)
 psf=shift(psf,n/2,n/2.)
 return
end

PRO getimage,c_image
 common sizes,l
 common imagedescrip,noise
;-----------------------

; file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\stacked_new_349_float.FIT'
file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\KING.fit'
;-----------------------
; file='/home/pth/SCIENCEPROJECTS/moon/ANDREW/stacked_new_349_float.FIT'
; file='KING.fit'
;-----------------------
 c_image=readfits(file)
;.............................
; add some noise if you want
 c_image=c_image/max(c_image)*50000.+10.*randomn(seed)
;.............................
 l=size(c_image,/dimensions)
 ll=min(l)
 c_image=c_image(0:ll-1,0:ll-1)	; clip so its square
 c_image=congrid(c_image,128,128) ; resize to 2^n
 l=size(c_image,/dimensions)
;--------------------------------------------------------
; measure the noise in the high-pass filtered image
 nn=3
 noise=c_image-smooth(c_image,nn,/edge_truncate)
 noise=sqrt(mean(noise^2))
 noise=10.0
 return
 end
;========================
common circle,x0,y0,radius,radius_surface
common errors,err_on_disc,err_off_disc
common c_image,c_image,n
common masks,mask,inverse_mask,n_mask,n_invmask
common folded,folded
common merit,merit
common xy,x,y,r
!P.MULTI=[0,1,1]
window,1,xsize=800,ysize=700
merit=0
; get an image to fold
getimage,c_image
setupsupportforlunardisc2,c_image,mask
n_mask=n_elements(where(mask eq 1))
inverse_mask=abs(mask-1)
n_invmask=n_elements(where(inverse_mask eq 1))
l=size(c_image,/dimensions)
if (l(0) ne l(1)) then stop
n=l(0)
; set up stuff for mpfit.........................
	xr=findgen(l(0))
	yc=findgen(l(1))
     X = XR # (YC*0 + 1)      ;       eqn. 1
     Y = (XR*0 + 1) # YC      ;       eqn. 2
     r=sqrt((x-n/2.)^2+(y-n/2.)^2)
;.................................................
; start settings for the PSF
a=0.0d0
b=1.3d0
c=2.0d0
a0=	5.0d1
build_psf,a0,a,b,c,n,psf
surface,psf
;fold c_image with the PSF - this is now the target
folded=double(fft(fft(c_image,-1,/double)*fft(psf,-1,/double),1,/double))
tvscl,folded

 ; Define the fractional tolerance:
   ftol = 1.0e-10

   ; Define the starting point:
   P = [a,b ,c,a0]


   ; Define the starting directional vectors in column format:
   xi = TRANSPOSE([[1.0, 0.0, 0.0,0.0],[0.0,1.0,0.0,0.0],[0.0, 0.0, 1.0,0.0],[0.0,0.0,0.0,1.0]])

   ; Minimize the function:
   POWELL, P, xi, ftol, fmin, 'EVALUATE_PSF'

   ; Print the solution point:
   PRINT, 'Solution point: ', P

   ; Print the value at the solution point:
   PRINT, 'Value at solution point: ', fmin

end