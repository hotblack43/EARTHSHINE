; read exp1
obs1=readfits('HGL/exp1/observed_image_JD2456104.8770674.fits')
modl1=readfits('HGL/exp1/synth_folded_scaled_shifted_JD2456104.8770674.fits')
diff1=obs1-modl1
; exp2
obs2=readfits('HGL/exp2/observed_image_JD2456104.8770674.fits')
modl2=readfits('HGL/exp2/synth_folded_scaled_shifted_JD2456104.8770674.fits')
diff2=obs2-modl2
d=[diff1,diff2]
tvscl,hist_equal(d)
writefits,'diffs.fits',d
end
