; Calculates the lunar flux at Earth using formulae in Allen Astrophysical Quantities.
;
V10=+0.23	
rdelta=0.0026
openw,44,'lunar_irradiance_Allen.dat'
for phase_angle=-180,180,1 do begin
phase=abs(phase_angle)
phaselaw=0.026*phase+4.0e-9*phase^4
V=5.0*alog10(rdelta)+V10+phaselaw
printf,44,phase_angle,10^(-V/2.5)
endfor
close,44
data=get_data('lunar_irradiance_Allen.dat')
ph=reform(data(0,*))
fl=reform(data(1,*))
plot_io,ph,fl,psym=7
end
