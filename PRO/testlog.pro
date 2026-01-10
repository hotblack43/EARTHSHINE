im1=readfits('NOISEADDED_161/OUTPUT/BBSO_CLEANED_LOG/LunarImg_0003.fit')
im2=readfits('NOISEADDED_161/OUTPUT/BBSO_CLEANED/LunarImg_0003.fit')
diff=(im1-im2)/im1*100.0
writefits,'diff.fits',diff
end
