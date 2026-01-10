PSF=readfits('Vega_PSF.fit')
fit=readfits('HAPKE_fitted.fit')
obs=readfits('observed.fit')
convolved=fft(fft(PSF,-1)*fft(fit,-1),1)
convolved=sqrt(double(convolved*conj(convolved)))
!P.MULTI=[0,2,2]
contour,/isotropic,fit,title='Fitted',/cell_fill,nlevels=100
contour,/isotropic,convolved,title='convolved',/cell_fill,nlevels=100
contour,/isotropic,obs,title='observed',/cell_fill,nlevels=100
plot,convolved(*,350)
oplot,obs(*,350)/mean(obs)*mean(convolved),color=fsc_color('blue')
end

