fixim=readfits('fix.fits')
floatim=readfits('float.fits')
doubleim=readfits('double.fits')
longim=readfits('long.fits')
help
print,'------------------'
print,'fix mean:',mean(fixim)
print,fixim(0:10)
print,'------------------'
print,'float mean:',mean(longim)
print,longim(0:10)
print,'------------------'
print,'double mean:',mean(doubleim)
print,doubleim(0:10)
print,'------------------'
print,'long mean:',mean(longim)
print,longim(0:10)
print,'------------------'
end
