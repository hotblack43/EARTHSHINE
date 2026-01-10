ref=readfits('veryspcialimageSSA1p000.fits')
im=readfits('veryspcialimageSSA0p000.fits')
n=20
openw,33,'shifts.dat'
for i=0,n-1,1 do begin
dx=randomn(seed)
dy=randomn(seed)
im2=shift_sub(im,dx,dy)
im2b=shift_sub_cubic(im,dx,dy)
;
shifts1=alignoffset(sobel(im2),sobel(ref),corr1)
shifts2=alignoffset((im2),(ref),corr2)
shifts4=alignoffset((im2b),(ref),corr3)
print,corr1,corr2,corr3
err1=sqrt((dx-shifts1(0))^2+(dy-shifts1(1))^2)
err2=sqrt((dx-shifts2(0))^2+(dy-shifts2(1))^2)
err4=sqrt((dx-shifts4(0))^2+(dy-shifts4(1))^2)
printf,33,err1,err2,err4
print,err1,err2,err4
endfor
close,33
data=get_data('shifts.dat')
print,'1: ',mean(total(reform(data(0,*))^2))
print,'2: ',mean(total(reform(data(1,*))^2))
print,'3: ',mean(total(reform(data(2,*))^2))
end
