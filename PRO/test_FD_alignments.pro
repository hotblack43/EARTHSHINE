im1=readfits('/home/pth/Desktop/ASTRO/EARTHSHINE/M15/DATA/doghouse_image87.fit')
im2=shift_sub(im1,12.245,-22.34)
shifts=alignoffset(im1,im2,corr)
print,'Using alignoffset shifts are: ',shifts,' R= ',corr
;-----------------
FD1=fft(im1,-1,/double)
FD2=fft(im2,-1,/double)
shifts=alignoffset(FD1,FD2,corr)
print,'Using complex FD shifts are: ',1./shifts/512.,' R= ',corr
FD1=double(FD1*conj(FD1))
FD2=double(FD2*conj(FD2))
shifts=alignoffset(FD1,FD2,corr)
print,'Using real FD shifts are: ',1./shifts/512.,' R= ',corr
end

