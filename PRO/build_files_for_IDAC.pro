PRO get_circle,l,coords,circle,radius,maxval
circle=dblarr(l)*0.0
astep=0.1d0
x0=coords(0)
y0=coords(1)
for angle=0.0d0,360.0d0-astep,astep do begin
        x=x0+radius*cos(angle*!dtor)
        y=y0+radius*sin(angle*!dtor)
        circle(x,y)=maxval
endfor
return
end

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

PRO buildPSF,im,PSF_out,size,x0,y0,radius,radius_2d
;
l=size(im,/dimensions)
nx=l(0)
ny=l(1)
if (file_test('moon_circle_data.dat') eq 0) then begin
print,'Click on three points on the rim of the Moon'
;
contour,im,/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101
device,/cursor_crosshair
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
print,'Using existing file!'
openr,45,'moon_circle_data.dat'
readf,45,x1,y1
readf,45,x2,y2
readf,45,x3,y3
close,45
endelse
fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
print,x0,y0,radius
for iangle=0.0,360.0,0.1 do plots,x0+radius*cos(iangle*!dtor),y0+radius*sin(iangle*!dtor),psym=3
print,'Now click on a radius at a point where the aureole is strongest'
cursor,x4,y4
angle=atan((y4-y0)/(x4-x0)) ; in radians
angle=angle/!pi*180.0
print,'Angle=',angle
openw,67,'radial_profile.dat'
for r=radius,10.*radius,1.0 do begin
	x=x0+r*cos(angle*!dtor)
	y=y0+r*sin(angle*!dtor)
	if (x ge 0 and x le nx-1 and y ge 0 and y le ny-1) then begin
		print,x,y,im(x,y)
		plots,x,y,psym=3
		printf,67,r-radius,im(x,y)
	endif
endfor
close,67
data=get_data('radial_profile.dat')
radial=data(0,*)
profile=data(1,*)
plot_oo,data(0,*),data(1,*),psym=7,xrange=[1,100]
X = FINDGEN(nx) # REPLICATE(1.0, ny)
Y = REPLICATE(1.0, nx) # FINDGEN(ny)
radius_2d=sqrt((x-x0)^2+(y-y0)^2)
PSF_out=INTERPOL(profile,radial-1.,radius_2d)
; ensure that none are negative
PSF_out=PSF_out-min(PSF_out)
; lop off the far tail
idx=where(PSF_out lt max(PSF_out)/500.)
PSF_out(idx)=0.0
return
end



; sets up the invariable files for the IDAC deconvolution
;
file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\stacked_new_349_float.FIT'
file='./ANDREW/stacked_new_349_float.FIT'
file='./KINGimages/KING_0000.fit'
; get size
im0=readfits(file,header)
print,'Using file ',file
im0=congrid(im0,128,128)	; must scale size to 2^N
imin=im0
writefits,'image_used.fit',imin,header
l=size(imin,/dimensions)
;
skylevel=100.0
sky=imin*0.0+skylevel
w=imin*0.0+1.0
conv_wf=imin*0.0+1.0
conv_sup=imin*0.0+1.0
obj_sup=imin*0.0+1.0
psf_sup=imin*0.0+1.0

; write out the actual folded image
im=imin
im=float(im/max(im)*(2L^16-1))
; make a data cube of such images, each different from
; the first by the noise added
nx=l(0)
ny=l(1)
nims=10
for i=0,nims-1,1 do begin
if (i eq 0) then cube=im+100.+randomn(seed,nx,ny)
if (i gt 0) then cube=[[[cube]],[[im+100.+randomn(seed,nx,ny)]]]
endfor
help,cube
writefits,'conv',cube
;writefits,'conv',im

; write out a utility frame with weights
writefits,'conv_wf',float(conv_wf)

; build the PSF from the image aureole and write it out
buildPSF,imin,PSF,nx,x0,y0,radius,radius_2d
im=psf
im=float(im/max(im)*(2L^16-1))
writefits,'psf',float(im)

; write out a guess at the real object image
im=imin
im=float(im/max(im)*(2L^16-1))
mask=radius_2d lt radius+1
writefits,'obj',float(im*mask)	; use of mask removes sky outside disc

; write the sky frame
writefits,'sky',float(sky)

; write out a bunch of utility frames
ones=float(im*0+1)
writefits,'w',float(ones)
writefits,'conv_sup',float(ones)
writefits,'conv_wf',float(ones)
writefits,'psf_sup',float(ones)
writefits,'obj_sup',float(ones*mask)
writefits,'conv_sup',ones
end
