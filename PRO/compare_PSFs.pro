LAMBERT_PSF=readfits('LAMBERT_PSF.fit')
HAPKE_PSF=readfits('HAPKE_PSF.fit')
l=size(HAPKE_PSF,/dimensions)
!P.MULTI=[0,1,3]
a=4
surface,rebin(LAMBERT_PSF,l(0)/a,l(1)/a),/lego,title='Calculated Lambert PSF'
surface,rebin(HAPKE_PSF,l(0)/a,l(1)/a),/lego,title='Calculated Hapke PSF'
surface,rebin(HAPKE_PSF+LAMBERT_PSF,l(0)/a,l(1)/a),/lego,title='Hapke+Lambert PSF'
end
