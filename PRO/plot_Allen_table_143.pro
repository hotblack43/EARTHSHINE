!P.MULTI=[0,1,2]
file='Allen_table_143.dat'
data=get_data(file)
alfa=reform(data(0,*))
delta_mag=reform(data(1,*))
phi_of_alpha=reform(data(2,*))
;
plot,alfa,delta_mag,psym=7,xtitle='Sun,Moon,Earth angle',ytitle='Magnitude difference',charsize=2
; get formula p. 143
V10=+0.23
rdelta=0.0026

phase=indgen(101)/100.*180.
phaselaw=0.026*phase+4.0e-9*phase^4
V=5.0*alog10(rdelta)+V10+phaselaw
oplot,phase,V-V(0)
; plot faktor
plot_io,alfa,10^(delta_mag/2.5),psym=7,xtitle='Sun,Moon,Earth angle',ytitle='Flux (arb. units)',charsize=2
oplot,phase,10^((V-V(0))/2.5)
end
