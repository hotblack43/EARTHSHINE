radius=0.25	; lunar radiusin degrees
phase=0.5	; fraction illuminated at half moon
area=!pi*radius^2*phase*3600.^2	; area of half of the disc
print,'Half of Lunar disc area',area, ' square arc seconds'	; in square arc seconds
;
;V_moon=-12.7	; Full Moon V mag
phaselaw=0.13	; approx at half moon
V_moon=0.23+5.0*alog10(2.57e-3)-2.5*alog10(phaselaw)
print,'V BS: ',V_moon,' (irradiance)'
flux_moon=10^(-V_moon/2.5)	; proportional to irradiance at that phase
flux_DS=flux_moon/10000.	; proportional to DS irradiance 
V_DS=-2.5*alog10(flux_DS)	; DS irradiance in magnitudes
print,'V DS:',V_DS, '(irradiance)'
print,'V DS:',V_DS-2.5*alog10(1./area), '(mag/sq asec)'
print,'Sky brightness: 21.9 mag/sq asec'
print,'Ratio DS/sky: ',10^((V_DS-2.5*alog10(1./area)-21.9)/(-2.5))
end
