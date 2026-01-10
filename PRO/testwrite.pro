im=randomn(seed,512,512)
writefits,'fix.fits',fix(im)
writefits,'float.fits',float(im)
writefits,'double.fits',double(im)
writefits,'long.fits',long(im)
end
