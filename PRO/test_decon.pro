 stack=readfits('2455945.1776847MOON_V_AIR.fits.gz')
 psf=readfits('psf_deconvolved_avg.fits')
 psf=psf-min(psf)
idx=where(psf eq max(psf))
coords=array_indices(psf,idx)
 psf=shift(psf,-coords(0),-coords(1))
idx=where(psf eq max(psf))
print,array_indices(psf,idx)
 surface,psf
 ideal=readfits('ideal_LunarImg_SCA_0p310_JD_2455945.1776847.fit')
 out=fft(fft(ideal,-1,/double)*fft(psf,-1,/double),1,/double)
 writefits,'out.fits',reverse(float(sqrt(out*conj(out))),1)
 writefits,'im.fits',avg(stack,2)
 end
