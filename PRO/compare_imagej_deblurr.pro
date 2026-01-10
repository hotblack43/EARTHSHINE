deblurred=readfits('subim_deblurred_mrnsd_fft0.0785_ref-1.fits')
subim=readfits('subim.fits')
plot,subim(*,256)+100.0,/ylog
oplot,deblurred(*,256)+100,color=fsc_color('red')
end
