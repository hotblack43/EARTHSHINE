PRO denonlinearize,im,c0,c1,c2,corrected
corrected=c0+c1*im+c2*im^2
return
end

im=readfits('./FLATTEN/DARKCURRENTREDUCED/2455865.7572192MOON_VE1_AIR_DCR.fits')
c0=24.0554
c1=1.08904
c2=-2.58255e-6
denonlinearize,im,c0,c1,c2,corrected
writefits,'fixed.fits',corrected
diff=corrected-im
writefits,'diff.fits',diff
writefits,'pct.fits',diff/im*100.
end

