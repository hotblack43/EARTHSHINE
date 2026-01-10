FUNCTION smearing, X, Y, A
common stuff,lunar_disk,iflag,smeared_disk,psf,subim,sky
;----------------------------------------------------------


	l=size(lunar_disk,/dimensions)
	scale=a(0)
	factor=a(1)
	lift=a(2)
 	get_psf_CIE,l,psf,scale
 	smeared_disk=factor*float(fft(fft(psf,-1)*fft(lunar_disk,-1),1))*sky+lift
print,format='(a,4(1x,g20.9))','a,RMSE:',a,sqrt(total(((subim-smeared_disk)*sky)^2)/l(0)/l(1))
   RETURN,smeared_disk
END

PRO fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
; Fits a circle that passes through the three designated coordinates
a=[[x1,y1,1.0],[x2,y2,1.0],[x3,y3,1.0]]
d=[[x1*x1+y1*y1,y1,1.0],[x2*x2+y2*y2,y2,1.0],[x3*x3+y3*y3,y3,1.0]]
e=[[x1*x1+y1*y1,x1,1.0],[x2*x2+y2*y2,x2,1.0],[x3*x3+y3*y3,x3,1.0]]
f=[[x1*x1+y1*y1,x1,y1],[x2*x2+y2*y2,x2,y2],[x3*x3+y3*y3,x3,y3]]
a=determ(a,/check,/double)
d=-determ(d,/check,/double)
e=determ(e,/check,/double)
f=-determ(f,/check,/double)
;
x0=-d/2./a
y0=-e/2./a
radius=sqrt((d*d+e*e)/4./a/a-f/a)
return
end

PRO make_circle,x0,y0,r,x,y
angle=findgen(6000)/6000.*360.0
;idx=where(angle gt 30 and angle lt 150)
;angle=angle(idx)
x=fix(x0+r*cos(angle*!dtor))
y=fix(y0+r*sin(angle*!dtor))
; make another layer
x=[x,fix(x0+(r+1)*cos(angle*!dtor))]
y=[y,fix(y0+(r+1)*sin(angle*!dtor))]
; make another layer
x=[x,fix(x0+(r-1)*cos(angle*!dtor))]
y=[y,fix(y0+(r-1)*sin(angle*!dtor))]
return
end

PRO get_psf_CIE,l,psf,scale
psf=dblarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r=sqrt((i-l(0)/2)^2+(j-l(1)/2.)^2)
		psf(i,j)=exp(-abs(r/scale))
	endfor
endfor
; shift the psf to the origin
psf=shift(psf,l(0)/2,l(1)/2.)
; normalize it
psf=psf/total(psf,/double)
print,total(psf)
return
end

;============= MAIN PROGRAMME =====================
common stuff,lunar_disk,iflag,smeared_disk,psf,subim,sky
read_jpeg,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\lunareclipseAugust2008\DATA\img_0847.jpg',im
im=double(reform(im(0,*,*)+im(1,*,*)+im(2,*,*)))
 x=1900
 y=2000
 radius=100
 w=radius*1.7
subim=im(x-w:x+w,y-w:y+w)
contour,subim^4,/isotropic
x0=193.3
y0=179.43439
radius=104.9

; cursor,x1,y1
 ;wait,1
 ;cursor,x2,y2
 ;wait,1
 ;cursor,x3,y3
 ;wait,1
 ;fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
 ;print,x0,y0,radius

; make radius^2 array in subim
l=size(subim,/dimensions)
r2=subim*0.0
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
r2(i,j)=((i-x0)^2+(j-y0)^2)/radius^2
endfor
endfor
contour,r2,/overplot,levels=indgen(10)/2.,c_labels=indgen(10)*0+1
; define index for sky outside the lunar disk
idx=where(r2 le 1.0)
sky=subim*0.0+1.0
sky(idx) = 0.0
; define index for disk inside the lunar disk
idx=where(r2 ge 1.0)
disk=subim*0.0+1.0
disk(idx) = 0.0
lunar_disk=subim*disk
;
;  now minimze on the sky by convolving the disk with the PSF
XR=indgen(l(0))
YC=indgen(l(1))
 X = XR # (YC*0 + 1)
 Y = (XR*0 + 1) # YC
 ; set up initial guesses for PSF params
 scale=7.74d0
 factor=69826.80d0
 lift=0.0d0
 a=[scale,factor,lift]
iflag=0	; i.e. let the convolution be calculated
err=sqrt(subim*sky)+1.0
p = mpfit2dfun('smearing', x, y, subim*sky, err, a,yfit=yhat,/DOUBLE,status=s,perror=pfejl,gtol=1e-12,ftol=1.0e-12)
print,'STATUS=',s

end
