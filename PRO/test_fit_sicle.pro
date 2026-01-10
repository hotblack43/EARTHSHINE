

openw,92,'trash13.dat'
w=5
sicle=readfits('sicle.fits')
idx=where(sicle eq 1)
coords=array_indices(sicle,idx)
x=coords(0,*)
y=coords(1,*)
n=n_elements(idx)
startguess=[327.,281.]
ic=0
for ix=startguess(0)-w,startguess(0)+w,1 do begin
for iy=startguess(1)-w,startguess(1)+w,1 do begin
for i=0,n-1,1 do begin
r=sqrt((x(i)-ix)^2+(y(i)-iy)^2)
if (ic eq 0) then rlist=r
if (ic gt 0) then rlist=[rlist,r]
ic=ic+1
endfor
printf,92,ix,iy,stddev(rlist),mean(rlist),median(rlist)
endfor
endfor
close,92
data=get_data('trash13.dat')
x=reform(data(0,*))
y=reform(data(1,*))
std=reform(data(2,*))
men=reform(data(3,*))
med=reform(data(4,*))
idx=where(std eq min(std))
print,'x0,y0,r: ',x(idx),y(idx),med(idx)
end
