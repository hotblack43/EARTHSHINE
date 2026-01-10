PRO make_circle,x0,y0,r,circle_im
circle_im=findgen(512,512)*0
n=r*2.2*!pi+1
angle=findgen(n)/float(n)*360.0
cosan=cos(angle*!dtor)
sinan=sin(angle*!dtor)
x=fix(x0+r*cosan)
y=fix(y0+r*sinan)
x=fix(x0+(r+1)*cosan)
y=fix(y0+(r+1)*sinan)
x=fix(x0+(r-1)*cosan)
y=fix(y0+(r-1)*sinan)
circle_im(x,y)=1
return
end

pro findbettercircle,sicle,startguess,x0,y0,r0
; will find a better fitting circle, giving a starting guess
openw,92,'trash13.dat'
w=5
idx=where(sicle eq 1)
coords=array_indices(sicle,idx)
x=coords(0,*)
y=coords(1,*)
n=n_elements(idx)
ic=0
for ix=startguess(0)-w,startguess(0)+w,1 do begin
for iy=startguess(1)-w,startguess(1)+w,1 do begin
for rad=startguess(2)-5.,startguess(2)+5.,.8745 do begin
make_circle,ix,iy,rad,circle_im
printf,92,ix,iy,rad,total(abs(sicle*circle_im))
endfor
endfor
endfor
close,92
data=get_data('trash13.dat')
x=reform(data(0,*))
y=reform(data(1,*))
r=reform(data(2,*))
tot=reform(data(3,*))
idx=where(tot eq max(tot))
print,'x,y,r: ',x(idx),y(idx),r(idx)
x0=x(idx)
y0=y(idx)
r0=r(idx)
end

startguess=[315.,237.,140.]
im=readfits('sicle.fits')
findbettercircle,im,startguess,x0,y0,r0
end
