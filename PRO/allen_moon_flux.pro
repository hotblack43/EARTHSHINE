FUNCTION allen_moon_flux,phase_angle
; Calculates the lunar flux at Earth using 
; formulae in Allen Astrophysical Quantities.
;
V10=+0.23	
rdelta=0.0026
phase=abs(phase_angle)
phaselaw=0.026*phase+4.0e-9*phase^4
V=5.0*alog10(rdelta)+V10+phaselaw
value=10^(-V/2.5)
return,value
end
