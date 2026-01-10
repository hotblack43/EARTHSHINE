;----------------------------
ideal=1.01+readfits(/silent,'ideal_testimage_halocancellation.fits')
idtot=total(ideal,/double)
; Generate the PSF by convolving a delta function
testimage=dblarr(512,512)
testimage(256,256)=1.0d0*512.*512.
writefits,'imagetofold.fits',testimage
str='./justconvolve imagetofold.fits out.fits 1.76'
spawn,str
PSFreal=readfits('out.fits')
PSFreal=shift(PSFreal,256,256)
;----------------------------
writefits,'imagetofold.fits',ideal
; first generate a halo image using one alfa
str='./justconvolve imagetofold.fits out.fits 1.741'
spawn,str
halo=readfits(/silent,'out.fits')
; then 'deconvolve' it using a  slightly wrong alfa
halo_deconv=fft(fft(halo,-1,/double)/fft(PSFreal,-1,/double),1,/double)
; then forward convolve to 1.74
writefits,'imagetofold.fits',double(halo_deconv)
str='./justconvolve imagetofold.fits out.fits 1.74'
halo2=readfits(/silent,'out.fits')
halo2=halo2-mean(halo2(0:10,0:10))
writefits,'imagetofold.fits',ideal
str='./justconvolve imagetofold.fits out.fits 1.74'
spawn,str
halo=readfits(/silent,'out.fits')
halo=halo-mean(halo(0:10,0:10))
; plot difference between the two
diff=(halo-halo2)/halo*100.0
plot_io,xstyle=3,diff(*,256)
end
