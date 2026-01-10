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

PRO buildPSF,im,PSF_out,sizeout
;
l=size(im,/dimensions)
nx=l(0)
ny=l(1)
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
radius=sqrt((x-x0)^2+(y-y0)^2)
PSF_out=INTERPOL(profile,radial-1.,radius)
PSF_out=congrid(PSF_out,sizeout,sizeout)
return
end

im_in=readfits('./ANDREW/stacked_new_349_float.FIT')
im_in=readfits('/media/XTEND/Ahmad Data/KEDF Test by Point source/KEDF735_L/2455620.4194125AIR_L_P0.fits')
size=128
buildPSF,im_in,PSF_out,size
help
end
