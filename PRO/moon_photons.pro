 ; Code to simulate the flux of photons at various wavelengths
 ; based on eq. 3.4 in Per Knutssons PhD thesis.
 ; load the airmass=1.5 solar spectrum
 file='ASTMG173.noheader'
 data=get_data(file)
 wave=reform(data(0,*))
 solar_etr=reform(data(1,*))
 solar_tilt=reform(data(2,*))
 ; get the terrestrial reflectance
 get_reflectance_spectrum,wave,reflectance
 ;
 ; calculate the Moonshine spectrum
 moon_spectrum_etr=solar_etr*spectral_moon_albedo(wave)
 moon_spectrum_tilt=solar_tilt*spectral_moon_albedo(wave)
 ; calculate the Earthshine spectrum
 earthshine_spectrum=moon_spectrum_tilt*reflectance
 ;
 ; get the filter transmissions
 !P.MULTI=[0,1,1]
 get_UBV,wave,U,B,V,R,I
 plot,i(0,*),i(1,*)*100.,xtitle='Wavelength (nm)',ytitle='Filter transmission (%)',charsize=1.7,xrange=[300,1000]
 oplot,b(0,*),b(1,*)*100.
 oplot,V(0,*),v(1,*)*100.
 oplot,R(0,*),r(1,*)*100.
 oplot,u(0,*),u(1,*)*100.
 ;
 !P.multi=[0,3,3]
 plot,wave,solar_etr,xrange=[250,1500],xtitle='Wavelength (nm)',ytitle='Solar spectrum (Etr)',charsize=1.7
 plot,wave,moon_spectrum_etr,xrange=[250,1500],xtitle='Wavelength (nm)',ytitle='Moonshine spectrum ETR',charsize=1.7
 plot,wave,earthshine_spectrum,xrange=[250,1500],xtitle='Wavelength (nm)',ytitle='Earthshine spectrum',charsize=1.7
 ;
 plot,wave,solar_tilt,xrange=[250,1500],xtitle='Wavelength (nm)',ytitle='Solar spectrum (Tilt)',charsize=1.7
 plot,wave,moon_spectrum_tilt,xrange=[250,1500],xtitle='Wavelength (nm)',ytitle='Moonshine spectrum TILT',charsize=1.7
 plot,wave,earthshine_spectrum,xrange=[250,1500],xtitle='Wavelength (nm)',ytitle='Earthshine spectrum',charsize=1.7
 ;
 ; define optical throughput function as product of lens transmission properties (here cuts at 380 nm and xxx) and
 ; CCD sensitivity curve
 get_CCD_sensitivity,wave,CCD_sensitivity
 Topt=(wave gt 0)	; if use filters then no IR_cutoff needed!
 ToptWL=(wave gt 0 and wave lt 700)	; if use WL then  IR_cutoff needed!
 h=1.0	; arbitrary units..
 c=1.0	; arbitrary units..
 ; perform 'photometry'
 nUsolar_etr=int_tabulated(wave,Topt*CCD_sensitivity*solar_etr*U(1,*))
 nBsolar_etr=int_tabulated(wave,Topt*CCD_sensitivity*solar_etr*B(1,*))
 nVsolar_etr=int_tabulated(wave,Topt*CCD_sensitivity*solar_etr*V(1,*))
 nRsolar_etr=int_tabulated(wave,Topt*CCD_sensitivity*solar_etr*R(1,*))
 nIsolar_etr=int_tabulated(wave,Topt*CCD_sensitivity*solar_etr*I(1,*))

 nUsolar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*solar_tilt*U(1,*))
 nBsolar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*solar_tilt*B(1,*))
 nVsolar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*solar_tilt*V(1,*))
 nRsolar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*solar_tilt*R(1,*))
 nIsolar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*solar_tilt*I(1,*))

 nUlunar_etr=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_etr*U(1,*))
 nBlunar_etr=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_etr*B(1,*))
 nVlunar_etr=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_etr*V(1,*))
 nRlunar_etr=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_etr*R(1,*))
 nIlunar_etr=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_etr*I(1,*))

 nUlunar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_tilt*U(1,*))
 nBlunar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_tilt*B(1,*))
 nVlunar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_tilt*V(1,*))
 nVlunar_tilt_noCCD=int_tabulated(wave,Topt*moon_spectrum_tilt*V(1,*))
 nRlunar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_tilt*R(1,*))
 nIlunar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_tilt*I(1,*))

 nUearthshine=int_tabulated(wave,Topt*CCD_sensitivity*earthshine_spectrum*U(1,*))
 nBearthshine=int_tabulated(wave,Topt*CCD_sensitivity*earthshine_spectrum*B(1,*))
 nVearthshine=int_tabulated(wave,Topt*CCD_sensitivity*earthshine_spectrum*V(1,*))
 nRearthshine=int_tabulated(wave,Topt*CCD_sensitivity*earthshine_spectrum*R(1,*))
 nIearthshine=int_tabulated(wave,Topt*CCD_sensitivity*earthshine_spectrum*I(1,*))

; estimate the White Light flux 
 nWLearthshine=int_tabulated(wave,ToptWL*CCD_sensitivity*earthshine_spectrum)
 nWLmoonshine=int_tabulated(wave,ToptWL*CCD_sensitivity*moon_spectrum_tilt)
 nWLmoonshine_noCCD=int_tabulated(wave,ToptWL*moon_spectrum_tilt)
;
 print,'Ratio of photon flux recorded by CCD at V to WL in Moonshine spectrum:',nVlunar_tilt/nWLmoonshine
 print,'Ratio of photon flux at V to WL in Moonshine spectrum:',nVlunar_tilt_noCCD/nWLmoonshine_noCCD
 ;
 print,'Ratio of photon flux at B to V Solar etr:',nBsolar_etr/nVsolar_etr
 print,'Ratio of photon flux at U to V Solar etr:',nUsolar_etr/nVsolar_etr
 print,'Ratio of photon flux at R to V Solar etr:',nRsolar_etr/nVsolar_etr
 print,'Ratio of photon flux at I to V Solar etr:',nIsolar_etr/nVsolar_etr
 print,'Ratio of photon flux at B to V Solar tilt:',nBsolar_tilt/nVsolar_tilt
 print,'Ratio of photon flux at U to V Solar tilt:',nUsolar_tilt/nVsolar_tilt
 print,'Ratio of photon flux at R to V Solar tilt:',nRsolar_tilt/nVsolar_tilt
 print,'Ratio of photon flux at I to V Solar tilt:',nIsolar_tilt/nVsolar_tilt
 LundOVERGoode=4.*(13./16.)^2
 print,'Ratio of photon flux at U to WL in Earthshine:',nUearthshine/nWLearthshine,' time factor:',1./(nUearthshine/nWLearthshine)
 print,'Ratio of photon flux at B to WL in Earthshine:',nBearthshine/nWLearthshine,' time factor:',1./(nBearthshine/nWLearthshine)
 print,'Ratio of photon flux at V to WL in Earthshine:',nVearthshine/nWLearthshine,' time factor:',1./(nVearthshine/nWLearthshine)
 print,'Ratio of photon flux at R to WL in Earthshine:',nRearthshine/nWLearthshine,' time factor:',1./(nRearthshine/nWLearthshine)
 print,'Ratio of photon flux at I to WL in Earthshine:',nIearthshine/nWLearthshine,' time factor:',1./(nIearthshine/nWLearthshine)
; plot spectra using Topt*CCD_sensitivity
!P.MULTI=[0,1,1]
plot,wave,earthshine_spectrum*Topt*CCD_sensitivity,xrange=[250,1200],xtitle='Wavelength (nm)',ytitle='Earthshine spectrum using CCD',charsize=1.7,xstyle=1
 factor=0.25
 oplot,u(0,*),u(1,*)*factor,thick=2
 oplot,b(0,*),b(1,*)*factor,thick=2
 oplot,v(0,*),v(1,*)*factor,thick=2
 oplot,r(0,*),r(1,*)*factor,thick=2
 oplot,i(0,*),i(1,*)*factor,thick=2
; and now the GRIZY system
; get the filter transmissions
!P.MULTI=[0,1,1]
 get_grizy,wave,gprime,rprime,iprime,zprime,yprime
U=gprime
B=rprime
V=iprime
R=zprime
I=yprime
 plot,i(0,*),i(1,*)*100.,xtitle='Wavelength (nm)',ytitle='Filter transmission (%)',charsize=1.7,xrange=[300,1000]
 oplot,b(0,*),b(1,*)*100.,color=fsc_color('blue')
 oplot,V(0,*),v(1,*)*100.,color=fsc_color('violet')
 oplot,R(0,*),r(1,*)*100.,color=fsc_color('red')
 oplot,u(0,*),u(1,*)*100.,color=fsc_color('blue')
 ;
 !P.multi=[0,3,3]
 plot,wave,solar_etr,xrange=[250,1500],xtitle='Wavelength (nm)',ytitle='Solar spectrum (Etr)',charsize=1.7
 plot,wave,moon_spectrum_etr,xrange=[250,1500],xtitle='Wavelength (nm)',ytitle='Moonshine spectrum ETR',charsize=1.7
 plot,wave,earthshine_spectrum,xrange=[250,1500],xtitle='Wavelength (nm)',ytitle='Earthshine spectrum',charsize=1.7
 ;
 plot,wave,solar_tilt,xrange=[250,1500],xtitle='Wavelength (nm)',ytitle='Solar spectrum (Tilt)',charsize=1.7
 plot,wave,moon_spectrum_tilt,xrange=[250,1500],xtitle='Wavelength (nm)',ytitle='Moonshine spectrum TILT',charsize=1.7
 plot,wave,earthshine_spectrum,xrange=[250,1500],xtitle='Wavelength (nm)',ytitle='Earthshine spectrum',charsize=1.7
 ;
 ; define optical throughput function as product of lens transmission properties (here cuts at 380 nm and xxx) and
 ; CCD sensitivity curve
 get_CCD_sensitivity,wave,CCD_sensitivity
 Topt=(wave gt 0)	; if use filters then no IR_cutoff needed!
 ToptWL=(wave gt 0 and wave lt 700)	; if use WL then  IR_cutoff needed!
 h=1.0	; arbitrary units..
 c=1.0	; arbitrary units..
 ; perform 'photometry'
 nUsolar_etr=int_tabulated(wave,Topt*CCD_sensitivity*solar_etr*U(1,*))
 nBsolar_etr=int_tabulated(wave,Topt*CCD_sensitivity*solar_etr*B(1,*))
 nVsolar_etr=int_tabulated(wave,Topt*CCD_sensitivity*solar_etr*V(1,*))
 nRsolar_etr=int_tabulated(wave,Topt*CCD_sensitivity*solar_etr*R(1,*))
 nIsolar_etr=int_tabulated(wave,Topt*CCD_sensitivity*solar_etr*I(1,*))

 nUsolar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*solar_tilt*U(1,*))
 nBsolar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*solar_tilt*B(1,*))
 nVsolar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*solar_tilt*V(1,*))
 nRsolar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*solar_tilt*R(1,*))
 nIsolar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*solar_tilt*I(1,*))

 nUlunar_etr=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_etr*U(1,*))
 nBlunar_etr=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_etr*B(1,*))
 nVlunar_etr=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_etr*V(1,*))
 nRlunar_etr=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_etr*R(1,*))
 nIlunar_etr=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_etr*I(1,*))

 nUlunar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_tilt*U(1,*))
 nBlunar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_tilt*B(1,*))
 nVlunar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_tilt*V(1,*))
 nVlunar_tilt_noCCD=int_tabulated(wave,Topt*moon_spectrum_tilt*V(1,*))
 nRlunar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_tilt*R(1,*))
 nIlunar_tilt=int_tabulated(wave,Topt*CCD_sensitivity*moon_spectrum_tilt*I(1,*))

 nUearthshine=int_tabulated(wave,Topt*CCD_sensitivity*earthshine_spectrum*U(1,*))
 nBearthshine=int_tabulated(wave,Topt*CCD_sensitivity*earthshine_spectrum*B(1,*))
 nVearthshine=int_tabulated(wave,Topt*CCD_sensitivity*earthshine_spectrum*V(1,*))
 nRearthshine=int_tabulated(wave,Topt*CCD_sensitivity*earthshine_spectrum*R(1,*))
 nIearthshine=int_tabulated(wave,Topt*CCD_sensitivity*earthshine_spectrum*I(1,*))

; estimate the White Light flux 
 nWLearthshine=int_tabulated(wave,ToptWL*CCD_sensitivity*earthshine_spectrum)
 nWLmoonshine=int_tabulated(wave,ToptWL*CCD_sensitivity*moon_spectrum_tilt)
 nWLmoonshine_noCCD=int_tabulated(wave,ToptWL*moon_spectrum_tilt)
;
 print,"Ratio of photon flux recorded by CCD at I' to WL in Moonshine spectrum:",nVlunar_tilt/nWLmoonshine
 print,"Ratio of photon flux at I' to WL in Moonshine spectrum:",nVlunar_tilt_noCCD/nWLmoonshine_noCCD
 ;
 print,'Ratio of photon flux at r to I Solar etr:',nBsolar_etr/nVsolar_etr
 print,'Ratio of photon flux at g to I Solar etr:',nUsolar_etr/nVsolar_etr
 print,'Ratio of photon flux at z to I Solar etr:',nRsolar_etr/nVsolar_etr
 print,'Ratio of photon flux at y to I Solar etr:',nIsolar_etr/nVsolar_etr
 print,'Ratio of photon flux at r to I Solar tilt:',nBsolar_tilt/nVsolar_tilt
 print,'Ratio of photon flux at g to I Solar tilt:',nUsolar_tilt/nVsolar_tilt
 print,'Ratio of photon flux at z to I Solar tilt:',nRsolar_tilt/nVsolar_tilt
 print,'Ratio of photon flux at y to I Solar tilt:',nIsolar_tilt/nVsolar_tilt
 LundOVERGoode=4.*(13./16.)^2
 print,'Ratio of photon flux at g to WL in Earthshine:',nUearthshine/nWLearthshine,' time factor:',1./(nUearthshine/nWLearthshine)
 print,'Ratio of photon flux at r to WL in Earthshine:',nBearthshine/nWLearthshine,' time factor:',1./(nBearthshine/nWLearthshine)
 print,'Ratio of photon flux at i to WL in Earthshine:',nVearthshine/nWLearthshine,' time factor:',1./(nVearthshine/nWLearthshine)
 print,'Ratio of photon flux at z to WL in Earthshine:',nRearthshine/nWLearthshine,' time factor:',1./(nRearthshine/nWLearthshine)
 print,'Ratio of photon flux at y to WL in Earthshine:',nIearthshine/nWLearthshine,' time factor:',1./(nIearthshine/nWLearthshine)
; plot spectra using Topt*CCD_sensitivity
!P.MULTI=[0,1,1]
plot,wave,earthshine_spectrum*Topt*CCD_sensitivity,xrange=[250,1200],xtitle='Wavelength (nm)',ytitle='Earthshine spectrum using CCD',charsize=1.7,xstyle=1
 factor=0.25
 oplot,u(0,*),u(1,*)*factor,thick=2,color=fsc_color('blue')
 oplot,b(0,*),b(1,*)*factor,thick=2,color=fsc_color('green')
 oplot,v(0,*),v(1,*)*factor,thick=2,color=fsc_color('orange')
 oplot,r(0,*),r(1,*)*factor,thick=2,color=fsc_color('red')
 oplot,i(0,*),i(1,*)*factor,thick=2,color=fsc_color('vermillion')
 end
