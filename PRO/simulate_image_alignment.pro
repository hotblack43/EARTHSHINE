openw,33,'shifterrors.dat'
im=readfits('HAPKE/ideal_LunarImg_0020.fit')
im=im/max(im)*50000.0
writefits,'usethisidealone.fits',im
;
for i=0,999,1 do begin
spawn,'rm out1.fits out2.fits'
; generate im1 from im
rannumstr=string(fix(randomu(seed)*10000))
str='./syntheticmoon usethisidealone.fits out1.fits 1.7 1 '+rannumstr
spawn,str
im1=readfits('out1.fits')
; generate im2 as shifted im
dx=randomn(seed)*4.
dy=randomn(seed)*4.
print,'shifting by: ',dx,dy
writefits,'shifted.fits',shift_sub(im,dx,dy)
str='./syntheticmoon shifted.fits out2.fits 1.7 1 '+rannumstr
spawn,str
im2=readfits('out2.fits')
tvscl,im1-im2
; now align them
shifts=alignoffset(im1,im2)
dx2=-shifts(0)
dy2=-shifts(1)
print,'error in shifts: ',dx-dx2,dy-dy2
printf,33,dx-dx2,dy-dy2
print,'--------------------------------'
endfor
close,33
data=get_data('shifterrors.dat')
errX=reform(data(0,*))
errY=reform(data(1,*))
errX=errX(sort(errX))
errY=errY(sort(errY))
!P.MULTI=[0,1,2]
histo,xtitle='X alignment error',errX,min(data),max(data),(max(data)-min(data))/50.
histo,xtitle='Y alignment error',errY,min(data),max(data),(max(data)-min(data))/50.
print,'99%-ile for X: ',errX(0.99*n_elements(errX))
print,' 1%-ile for X: ',errX(0.01*n_elements(errX))
print,'99%-ile for Y: ',errY(0.99*n_elements(errY))
print,' 1%-ile for Y: ',errY(0.01*n_elements(errY))
end
