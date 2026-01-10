file='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455736/2455736.8025325CALIBRATE2.fits'
im=readfits(file)
l=size(im,/dimensions)
if (n_elements(l) eq 2) then begin
print,'This is not a stack of images...'
stop
endif
n=l(2)
im=total(im,3)
writefits,'stack.fits',im
end
