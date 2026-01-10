; build a PSF by hand from an image of a star or a point source

imfile='/media/XTEND/Ahmad Data/KEDF Test by Point source/KEDF735_L/2455620.4194125AIR_L_P0.fits'
im=readfits(imfile)
; find the maximum
idx=where(im eq max(im))
coords=array_indices(im,idx)
print,coords
end
