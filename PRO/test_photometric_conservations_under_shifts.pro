file='FAKEOBSERVED/fake_observed_387.fits'
im0=readfits(file)
;im0(where(im0 lt 500))=0.0
im=im0
phot=total(im0,/double)
for cub=-0.4,-0.6,-0.01 do begin
openw,5,'phot.dat'
dx=randomn(seed)
dy=randomn(seed)
for alfa=-3.0,3.0,0.1 do begin
printf,5,(total(im,/double)-phot)/phot*100.0
im=shift_sub(im0,dx,dy)
im=rot(im0,alfa,cubic=cub)
endfor
close,5
data=get_data('phot.dat')
plot,data,ystyle=1,title='cub : '+string(cub)
print,min(data),max(data),cub,sqrt(min(data)^2+max(data)^2)
endfor
end
