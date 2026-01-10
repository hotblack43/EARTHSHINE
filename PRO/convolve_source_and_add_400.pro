im=readfits('source.fits')
idx=where(im eq 0)
spawn,'./justconvolve source.fits source_folded.fits 1.8 0'
im=readfits('source_folded.fits')
im(idx)=400
writefits,'brightside_folded_1p8.fits',im
end
