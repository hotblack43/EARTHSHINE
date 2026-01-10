dark=readfits('float_MHM_dark_6s.fits')
dark=long(dark)
print,mean(dark)
file='Stars_13frame_r1.fits'
im=readfits(file,h)
im=long(im)
l=size(im,/dimensions)
n=l(2)
for i=0,n-1,1 do begin
imm=reform(im(*,*,i))
print,mean(imm)
writefits,strcompress('extr_'+string(i)+'.fits',/remove_all),imm-dark,h
print,mean(imm-dark)
endfor
end
