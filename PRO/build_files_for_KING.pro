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

PRO buildPSF,im,PSF_out,size
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
return
end



; sets up the invariable files for the IDAC deconvolution
;
files=file_search('KINGimages/*KING*.fit',count=Nfiles)
files(0)='./ANDREW/stacked_new_349_float.FIT'
; get size
im0=readfits(files(0),header)
print,'Using file ',files(0)
im0=congrid(im0,128,128)
imin=im0
writefits,'image_used.fit',imin,header
l=size(imin,/dimensions)
sky=imin*0.0
w=imin*0.0+1.0
conv_wf=imin*0.0+1.0
conv_sup=imin*0.0+1.0
obj_sup=imin*0.0+1.0
psf_sup=imin*0.0+1.0
obj=imin	; base this on observed, not ideal, image!
; Build a possible PSF
; Define array dimensions:  
nx = l(0)& ny = l(1)
; Create X and Y arrays:  
X = FINDGEN(nx) # REPLICATE(1.0, ny)  
Y = REPLICATE(1.0, nx) # FINDGEN(ny)  
; Create gaussian Z:  
r2 = ((x-nx/2)^2+(y-ny/2)^2)
radius=sqrt(r2)
;psf =  exp(-r2/100.)	; simple guess at PSF
psf =  1./r2	; simple guess at PSF
psf(where(r2 eq 0))=100.

; modify header and save
if_double=0
im=imin
mask=radius le 16.
if (if_double eq 0) then im=float(im/max(im)*(2L^16-1))
if (if_double eq 1) then im=double(im/max(im)*(2L^16-1))
writefits,'KING_folded_im',im


if (if_double eq 0) then im=float(conv_wf)
if (if_double eq 1) then im=double(conv_wf)
writefits,'conv_wf',im

im=readfits('IDEAL/ideal_LunarImg_0000.fit')
im=congrid(im,128,128)
if (if_double eq 0) then im=float(im/max(im)*(2L^16-1))
if (if_double eq 1) then im=double(im/max(im)*(2L^16-1))
writefits,'obj',float(im)


buildPSF,imin,PSF,nx
im=psf
if (if_double eq 1) then  im=double(im/max(im)*(2L^16-1))
if (if_double eq 0) then  im=float(im/max(im)*(2L^16-1))
writefits,'psf',float(im)

im=sky
if (if_double eq 0) then im=float(im)
if (if_double eq 1) then im=double(im)
writefits,'sky',float(im)

if (if_double eq 0) then ones=float(im*0+1)
if (if_double eq 1) then ones=double(im*0+1)
writefits,'w',float(ones)
writefits,'KING_folded_im_sup',float(ones)
writefits,'KING_folded_im_wf',float(ones)
writefits,'psf_sup',float(ones)
writefits,'obj_sup',float(ones)
writefits,'conv_sup',ones
end
