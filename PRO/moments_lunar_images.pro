black=readfits('veryspcialimageSSA0p000.fits')
white=readfits('veryspcialimageSSA1p000.fits')
file='veryspcialimageSSA0p300.fits'
ntrials=100
albedomin=0.1
albedomax=0.4
openw,33,'moments.dat'
for itrial=0,ntrials-1,1 do begin
albedo=randomu(seed)*(albedomax-albedomin)+albedomin
grey=black*(1.-albedo)+white*albedo
writefits,'grey.fits',grey
seed=fix((systime(/seconds)-long(systime(/seconds)))*1e4)
str='./syntheticmoon grey.fits out.fits 1.7 30 '+string(seed)
spawn,str
im=readfits('out.fits')
printf,33,format='(5(1x,g20.15))',moment(im),albedo
print,format='(5(1x,g20.15))',moment(im),albedo
endfor
close,33
end
