; read the 'truth' image
imin=readfits('truth.fits')
nims=2000
for i=0,nims-1,1 do begin
dx=randomn(seed)
dy=randomn(seed)
print,dx,dy,i
imo=shift_sub(imin,dx,dy)
imo=smooth(imo,3)
writefits,strcompress('FAKEOBSERVED/'+'fake_observed_'+string(i)+'.fits',/remove_all),imo
endfor
end
