ideal=readfits('out.fits')
; generate the '1/75th' source image
im=ideal
factor=75.
idx=where(im lt max(smooth(im,3))/factor)
im(idx)=0
writefits,'source.fits',im
end
