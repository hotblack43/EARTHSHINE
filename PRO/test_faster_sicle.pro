PRO godoititbetter,startguess_in,im,x0,y0,r0
findbettercircle,im,startguess_in,x0,y0,r0; & print,'x0,y0,r0:',x0,y0,r0
startguess=[x0,y0,r0,2.,1.]
findbettercircle,im,startguess,x0,y0,r0 ;& print,'x0,y0,r0:',x0,y0,r0
startguess=[x0,y0,r0,1.,.33]
findbettercircle,im,startguess,x0,y0,r0 ;& print,'x0,y0,r0:',x0,y0,r0
return
end

pro findbettercircle,sicle,startguess,x0,y0,r0
; will find a better fitting circle, giving a starting guess
openw,92,'trash13.dat'
w=startguess(3)
stepsize=startguess(4)
idx=where(sicle eq 1)
coords=array_indices(sicle,idx)
x=coords(0,*)
y=coords(1,*)
n=n_elements(idx)
ic=0
for ix=startguess(0)-w,startguess(0)+w,stepsize do begin
for iy=startguess(1)-w,startguess(1)+w,stepsize do begin
for rad=startguess(2)-w,startguess(2)+w,stepsize do begin
isum=0
for j=0,n-1,1 do begin
radtest=sqrt((x(j)-ix)^2+(y(j)-iy)^2)
if (abs(radtest-rad) lt 1.0) then isum=isum+1
endfor
printf,92,ix,iy,rad,isum
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
print,'maxtot:',max(tot)
x0=x(idx)
y0=y(idx)
r0=r(idx)
end

startguess=[314.,235.,140.,7,2]
im=readfits('sicle.fits')
godoititbetter,startguess,im,x0,y0,r0
print,'Best x0,y0,r0:',x0,y0,r0
end
