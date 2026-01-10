observed=readfits('JACOB_observed.fits')
ideal=readfits('JACOB_ideal.fits')
help,observed,ideal
openw,1,'JACOB_observed.raw'
writeu,1,observed
close,1
openw,1,'JACOB_ideal.raw'
writeu,1,ideal
close,1
end

