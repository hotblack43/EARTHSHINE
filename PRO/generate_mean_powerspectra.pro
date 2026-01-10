; Generate the avrega (2D) power spectrum for a set of images
files=file_search('/media/HITACHI/BOOTSTRAPPEDOBSERVATINS/2456017.*_B_*',count=nim)
for i=0,nim-1,1 do begin
im1=readfits(files(i))
im1=im1/total(im1,/double)
z1=fft(im1,-1)
z1pow=sqrt(float(z1*conj(z1)))
if (i eq 0) then stack=z1pow
if (i gt 0) then stack=[[[stack]],[[z1pow]]]
endfor
;stack=avg(stack,2)
stack=median(stack,dimension=3)
writefits,'average_2d_pwrspectrum.fits',stack
end
