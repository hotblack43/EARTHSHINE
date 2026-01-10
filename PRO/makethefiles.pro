spawn,'./justconvolve ideal_testcase1.fits observed.fits 1.8 0'
; correct the 'observed' image by subtracting an estimated bias term
im=readfits('observed.fits')
im=im+400	; add a fake bias term
bias=mean(im(0:10,0:10))
im=im-bias
writefits,'observed.fits',im
; generate the '1/75th' source image
im=readfits('observed.fits')
factor=75.
idx=where(im lt max(smooth(im,3))/factor)
im(idx)=0
writefits,'source.fits',im
im=readfits('source.fits')
idx=where(im eq 0)
spawn,'./justconvolve source.fits brightside_folded_1p8.fits 1.8 0'
spawn,'rm timing.temp'
end

