im04=readfits('HAPKE0p4.fits')
im06=readfits('HAPKE0p6.fits')
im08=readfits('HAPKE0p8.fits')
;
diff_04_06_pct=(im04-im06)/im06*100.0
writefits,'diff_pct_hapke0406.fits',diff_04_06_pct
diff_08_06_pct=(im08-im06)/im06*100.0
writefits,'diff_pct_hapke0806.fits',diff_08_06_pct
end

