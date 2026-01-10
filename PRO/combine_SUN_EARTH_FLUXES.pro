T_Sun=5550.
T_EARTH=280.
T_Moon_HS=273.15+100.
T_Moon_Cs=273.15-153.
R_SUN=6.96e5*1e3	; Sun's radius in m	
R_EARTH=6371.*1e3	; Earth's radius in m
R_Moon=1738.*1e3	; Moon's radius in m
SE=1.496e11	; 1AU in m
ME=380000.*1e3	; Moon-Earth distance in m
Moon_albedo=0.05
Earth_albedo=0.3
;
x=911.
y=911.
wave=findgen(10000)*100.+10.
; First set up spectral fluxes 
Sun_Spectral_flux=planck(wave,T_Sun)*4.*!pi*R_SUN^2*1e-7	; W/Å
Earth_Spectral_flux=planck(wave,T_EARTH)*4.*!pi*R_EARTH^2*1e-7	; W/Å
Moon_HS_Spectral_flux=planck(wave,T_Moon_HS)*4.*!pi*R_Moon^2*1e-7	; W/Å
Moon_CS_Spectral_flux=planck(wave,T_Moon_CS)*4.*!pi*R_Moon^2*1e-7	; W/Å
;------------------------
; Calculate spectral intensities at 1AU
; short Wave contributions
Sunshine_at_Moon=Sun_Spectral_flux/SE^2
Sunshine_at_Earth=Sunshine_at_Moon
Moonshine_at_Earth=Sunshine_at_Moon*Moon_albedo*R_Moon^2/ME^2
;
Earthshine_at_Moon=Sunshine_at_Earth*Earth_albedo*R_EARTH^2/ME^2
Earthshine_at_Earth=Earthshine_at_Moon*Moon_albedo*R_Moon^2/ME^2
SW=Moonshine_at_Earth+Earthshine_at_Earth
;
print,'Moonshine/Earthshine:',int_tabulated(wave,Moonshine_at_Earth)/int_tabulated(wave,Earthshine_at_Earth)
; long Wave contributions
Moon_LW_at_Earth=Moon_HS_Spectral_flux/ME^2
HS_Moon_LW_at_Earth=Moon_HS_Spectral_flux/ME^2
CS_Moon_LW_at_Earth=Moon_CS_Spectral_flux/ME^2
Earth_LW_at_Moon=Earth_Spectral_flux/ME^2
Earth_LW_back_at_Earth=Earth_LW_at_Moon*R_Moon^2/ME^2
LW=Moon_LW_at_Earth+Earth_LW_back_at_Earth
CS_LW=Earth_LW_back_at_Earth+CS_Moon_LW_at_Earth
HS_LW=Earth_LW_back_at_Earth+HS_Moon_LW_at_Earth
;
; Sum up
Total=sw+lw
CS_TOTAL=sw+CS_LW
HS_TOTAL=sw+HS_LW
;
!P.MULTI=[0,1,2]
plot_io,wave/10000.,Total,xrange=[0,20],charsize=1.5,xtitle='Wavelength (microns)',ytitle='Flux [W/m^2/Å]',yrange=[1e-14,1e-9]
oplot,wave/10000.,Moonshine_at_Earth,linestyle=4
oplot,wave/10000.,Earthshine_at_Earth,linestyle=1
oplot,wave/10000.,Moon_LW_at_Earth,linestyle=2
oplot,wave/10000.,Earth_LW_back_at_Earth,linestyle=3
;
plot_io,wave/10000.,Moonshine_at_Earth/Total,xrange=[0,20],charsize=1.5,xtitle='Wavelength (microns)',ytitle='Relative Fluxes',ystyle=1,yrange=[1e-5,1],linestyle=4
oplot,wave/10000.,Earthshine_at_Earth/Total,linestyle=1
oplot,wave/10000.,Earth_LW_back_at_Earth/Total,linestyle=3
xyouts,4,1e-1,'Reflected Sunshine',/data
xyouts,1,1e-4,'SW Earthshine',/data
xyouts,5.7,3e-5,'LW Earthshine',/data
;
end
