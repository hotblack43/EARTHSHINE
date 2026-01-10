im1=readfits('Capella_coadded_iteration_2001.fits',/NOSCALE)
im2=readfits('Capella_coadded_iteration_2001_v2.fits',/NOSCALE)
diff=(im1-im2)/im2*100.0
surface,diff
end
