file='TUGcam1.jpg'
read_jpeg,file,im
im=total(im,1)/3

writefits,'TUGcam1.fit',im
;im=congrid(im,128,128)
l=size(im,/dimensions)
window,0
loadct,5
device,decomposed=0
contour,im,/cell_fill,/isotropic,nlevels=101,xstyle=1,ystyle=1
;
openw,5,'phis.dat'
; define pixel center coordinates of fisheyimage:
ac=184
bc=191
; fisheye circle radius
R=178.
; define map width and height
m=512/8
n=m
grid=fltarr(m,n)
;  define half width
w=n/2.
h=m/2.
; define grid middle
x0=w
y0=h
; scan across square grid
mina=1e5
maxa=-1e5
minb=1e5
maxb=-1e5
for i=-w,w-1,1 do begin
for j=-h,h-1,1 do begin
dx=i
dy=j
bigPhi=atan(sqrt(dx^2+dy^2),h)
littlephi=atan(abs(dy),abs(dx))
if (1 gt 0) then begin
if (dx ge 0 and dy ge 0) then begin
	littlephi2=littlephi
endif
if (dx lt 0 and dy ge 0) then begin
	littlephi2=!pi-littlephi
endif
if (dx lt 0 and dy lt 0) then begin
	littlephi2=!pi+littlephi
endif
if (dx ge 0 and dy lt 0) then begin
	littlephi2=2*!pi-littlephi
endif
endif
D=2.*bigPhi*R/!pi
a=D*cos(littlephi2)
b=D*sin(littlephi2)
a=a+ac
b=b+bc
grid(i+x0,j+y0)=im(a,b)
if (a lt mina) then mina=a
if (b lt minb) then minb=b
if (a gt maxa) then maxa=a
if (b gt maxb) then maxb=b
oplot,[a,a],[b,b],psym=3
endfor
endfor
window,1
loadct,5
device,decomposed=0
contour,/isotropic,grid,/cell_fill,nlevels=101,xstyle=1,ystyle=1
print,mina,maxa,minb,maxb
close,5
;
end
