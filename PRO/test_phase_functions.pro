

FUNCTION kattawareadams7171,phase
; Apj167 Kattaware and Admas eq. 17
; phase in RADIANS
value=4./3*cos(phase)*(1./4.*sin(2.*phase)+!pi/2-phase/2.)+1./3.*sin(phase)*(1.-cos(2.*phase))
return,value
end

FUNCTION flambert,beta
; from palle et al 2016 amnuscript eqn 2
value=((!pi-abs(beta))*cos(beta)+sin(beta))/!pi
return,value
end

FUNCTION wannjensen,phi
value=(sin(abs(phi))+(!pi-abs(phi))*cos(phi))/!pi
return,value
end

openw,33,'p.dat'
for phase=0.0,!pi,0.05 do begin
printf,33,phase,kattawareadams71(phase),flambert(phase),wannjensen(phase)
print,phase,kattawareadams71(phase),flambert(phase),wannjensen(phase)
endfor
close,33
data=get_data('p.dat')
plot,data(0,*),data(1,*),psym=7,xtitle='Lunar phase angle',ytitle='Phase function'
oplot,data(0,*),data(2,*),color=fsc_color('red'),psym=7
oplot,data(0,*),data(3,*),color=fsc_color('green')
end
