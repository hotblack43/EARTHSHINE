FUNCTION evaluate1,image,x0,y0,r
;
;	Evaluate correlation between image and circle
;
make_circle,x0,y0,r,x,y
image3=image*0.0
image3(x,y)=max(image)
image2=sobel(image)
idx=where(image2 lt 0.95*max(image2))
image2(idx)=0.0
;
corr=1./correlate(image2,image3,/double)
tvscl,image2+image3

return,corr
end

PRO fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius

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

PRO find_center_and_radius,im_in,x0,y0,r
im=im_in
; find center and radius
contour,im,/isotropic
cursor,x1,y1
wait,0.2
cursor,x2,y2
wait,0.2
cursor,x3,y3
wait,0.2
fitcircle3points,x1,y1,x2,y2,x3,y3,x00,y00,radius
letsdocircle,im,x00,y00,radius,x0,y0,r
return
end

FUNCTION petersfunc1,a
;
;	A circle is fitted
;
common moon,image
common keep,bestcorr
x0=a(0)
y0=a(1)
r=a(2)
corr=evaluate1(image,x0,y0,r)
if (corr lt bestcorr) then begin
    print,format='(a,3(1x,f8.3),1x,g18.9)','In petersfunc1:',a,corr
    bestcorr=corr
endif
return,corr
end


PRO fit_moon1,orgimage,x0_in,y0_in,r_in,x0,y0,r
; PURPOSE   - to find the center and radius of the Moon in the image orgimage
; INPUTS    - file,x0_in,y0_in,r_in: filename and initial guesses of center and radius
; OUTPUTS   - x0,y0,r
;----------------------------------------------------
;	Note - fits a circle
;----------------------------------------------------
common moon,image
x0=x0_in
y0=y0_in
r=r_in
image=orgimage
;
a=[x0,y0,r]
xi=[[1,0,0],[0,1,0],[0,0,1]]
ftol=1.e-8
POWELL,a,xi,ftol,fmin,'petersfunc1',iter=iter,/double
print,'Iter=',iter
;
x0=a(0)
y0=a(1)
r=a(2)
;
	POWELL,a,xi,ftol,fmin,'petersfunc1',iter=iter,/double
	print,'iter=',iter
;
return
end

PRO letsdocircle,image,x00,y00,radius,x0,y0,r
common facts,probableradius,probablex00,probabley00

fit_moon1,image,x00,y00,radius,x0,y0,r

return
end


PRO make_circle,x0,y0,r,x,y
angle=findgen(500)/500.*360.0
ran=randomu(seed)
angle1=angle*!dtor+ran
angle2=angle*!dtor-ran
idx=where(angle lt 90 or angle gt 270)
angle=angle(idx)
idx=where(angle1 lt !pi/2. or angle1 gt !pi*1.5)
angle1=angle1(idx)
idx=where(angle2 lt !pi/2. or angle2 gt !pi*1.5)
angle2=angle2(idx)

x=fix(x0+r*cos(angle*!dtor))
y=fix(y0+r*sin(angle*!dtor))

; make another layer outside first

x=[x,fix(x0+(r+1)*cos(angle1))]
y=[y,fix(y0+(r+1)*sin(angle1))]
; make another layer inside other two
;x=[x,fix(x0+(r-1)*cos(angle2))]
;y=[y,fix(y0+(r-1)*sin(angle2))]

return
end


PRO scaleANDshift,im_in,factor,dx,dy
; scale im_in UP by factor, then shift, the scale DOWN again
l=size(im_in,/dimensions)
im_in=congrid(im_in,l(0)*factor,l(1)*factor,/INTERP)
im_in=shift(im_in,dx*factor,dy*factor)
im_in=congrid(im_in,l(0),l(1),/INTERP)
return
end

PRO read_header,header,JD,exptime
string=header(where (strpos(header,'EXPTIME') eq 0))
exptime=float(strmid(string,9,strlen(string)-9))
string=header(where (strpos(header,'DATE-OBS') eq 0))
yy=fix(strmid(string,11,4))
mm=fix(strmid(string,16,2))
dd=fix(strmid(string,19,2))
string=header(where (strpos(header,'TIME-OBS') eq 0))
hh=fix(strmid(string,11,2))
mi=fix(strmid(string,14,2))
ss=float(strmid(string,17,6))
JD=double(julday(mm,dd,yy,hh,mi,ss))
return
end

common keep,bestcorr

;files=file_search('/home/pth/moon/ANDREW/DATA/moon*.FIT')
files=file_search('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\AUSTRALIAMOON\moon*.FIT')
n=n_elements(files)
;dark=readfits('/home/pth/moon/ANDREW/DATA/sydneydark.fit')
dark=readfits('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\AUSTRALIAMOON\sydneydark.fit')
for i=0,n-1,1 do begin
	bestcorr=1e20
	im_in=readfits(files(i),header)
	read_header,header,JD,exptime
	find_center_and_radius,im_in-dark,x0,y0,r
	print,format='(3(1x,f9.2),1x,f20.5,1x,a30)',x0,y0,r,JD,exptime,files(i)
endfor
end
