PRO scaleim,im
l=size(im,/dimensions)
im=rebin(im,l(0)/2,l(1)/2)
return
end

synt=readfits('synthetic.fits')
usethis=readfits('usethisidealimage.fits')
SSA1=readfits('veryspcialimageSSA1p000.fits')
SSA0p3=readfits('veryspcialimageSSA0p300.fits')
SSA0=readfits('veryspcialimageSSA0p000.fits')
scaleim,synt
scaleim,usethis
scaleim,SSA1
scaleim,SSA0p3
scaleim,SSA0
writefits,'three.fits',[SSA0p3,SSA0,SSA1]
writefits,'threescaled.fits',[hist_equal(SSA0p3),hist_equal(SSA0),hist_equal(SSA1)]
end
