lowpath='/media/OLDHD/pth/SAMSUNG/MOONDROPBOX/'
d1=readfits(lowpath+'JD2456076/2456076.8803215DARK_DARK.fits.gz')
m=readfits(lowpath+'JD2456076/2456076.7605692MOON_VE2_AIR.fits.gz')
d2=readfits(lowpath+'JD2456076/2456076.8161969DARK_DARK.fits.gz')
print,'mean dark 1: ',mean(d1)
print,'mean dark 2: ',mean(d2)
print,'mean corner 1 in MOON image: ',mean(m(0:10,0:10,*))
end
