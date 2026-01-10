im=readfits('youneedthis.fits')
openw,1,'float.raw'
writeu,1,float(im)
close,1
openw,1,'double.raw'
writeu,1,double(im)
close,1
print,'Float: min=',min(float(im)),' max= ',max(float(im)),' im(0,0)= ',float(im(0,0)),' im(13,400)= ',float(im(13,400))
print,'Float: min=',min(double(im)),' max= ',max(double(im)),' im(0,0)= ',double(im(0,0)),' im(13,400)= ',double(im(13,400))
;
im=readfits('PSF.fit')
openw,1,'PSFfloat.raw'
writeu,1,float(im)
close,1
openw,1,'PSFdouble.raw'
writeu,1,double(im)
close,1
print,'Float: min=',min(float(im)),' max= ',max(float(im)),' im(0,0)= ',float(im(0,0)),' im(13,400)= ',float(im(13,400))
print,'Float: min=',min(double(im)),' max= ',max(double(im)),' im(0,0)= ',double(im(0,0)),' im(13,400)= ',double(im(13,400))
end
