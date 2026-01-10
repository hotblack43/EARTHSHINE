truth=readfits('truth.fits')
truth=smooth(truth,5)
im_v2=readfits('Fake_coadded_iteration_2001_v2.fits')
im_v1=readfits('Fake_coadded_iteration_2001.fits')
delta_v2=(im_v2-truth)/truth*100.0
writefits,'pct_delta_v2.fits',delta_v2
delta_v1=(im_v1-truth)/truth*100.0
writefits,'pct_delta_v1.fits',delta_v1
end

