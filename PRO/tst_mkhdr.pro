im=readfits('lap.fits',h)
mkhdr,h2,im
sxaddpar, h2, 'PHASE', 36.432, 'Lunar phase angle'
writefits,'lap2.fits',im,h2
end
