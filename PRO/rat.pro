mo=readfits('best_model_image.fits')
obs=readfits('observed_image.fits')
imrat=obs/mo
;
tvscl,hist_equal(imrat)
end
