file='wehrli85.txt'
data=get_data(file)
lamda=reform(data(0,*))
flux=reform(data(1,*))
plot_io,lamda,flux,xtitle='Wavelength (nm)',ytitle='Flux [W/M!u2!n/nm]',xrange=[200,900],yrange=[1e-8,10],title='Spectral fluxes of Sun and Moon'
print,'Sun flux=',int_tabulated(lamda,flux),' W/sm'
full_moon_factor=10^((12.7-26.7)/2.5)
print,' Full Moon flux=',int_tabulated(lamda,flux)*full_moon_factor,' W/sm'
; Pase law
V10=+0.23
rdelta=0.0026
for phase=0,180,10 do begin
phaselaw=0.026*phase+4.0e-9*phase^4
phase_factor=10^(phaselaw/(-2.5))
combined_factor=full_moon_factor*phase_factor
print,phase,combined_factor
oplot,lamda,flux*combined_factor

endfor
end
