bias=readfits('TTAURI/superbias.fits')
file_stack='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1760145MOON_B_AIR.fits.gz'
file='/data/pth/DARKCURRENTREDUCED/SELECTED_4/2455945.1760145MOON_B_AIR_DCR.fits'
im=readfits(file,h)
stack=readfits(file_stack)
l=size(stack,/dimensions)
nims=l(2)
for i=0,nims-1,1 do begin
name=strcompress('/data/pth/ERASEMEWHENEVER/2455945.1760145_individual_from_stack_'+string(i)+'.fits',/remove_all)
tvscl,hist_equal(reform(stack(*,*,i))-bias)
writefits,name,reform(stack(*,*,i))-bias,h
endfor
end
