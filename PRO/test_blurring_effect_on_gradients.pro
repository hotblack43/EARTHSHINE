im=100.0+readfits('synthetic_2455864.fits.gz')
blurred=smooth(im,11)
diff=(blurred-im)/im
tvscl,diff
end
