FUNCTION BtimesS,phi,t,hapkeG
    hapkeG=0.6
    g = hapkeG
    if (phi EQ 0.0D) then begin
      B = 2.0
    endif else if (phi GT 0.0D AND phi LT (!DPI/2.0-0.00001)) then begin
      B = 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi)))
    endif else if (phi GE (!DPI/2.0-0.00001)) then begin
      B = 1.0
    endif
;   t = 0.1
    S = (2.0/(3*!DPI)) * ( (sin(phi) + (!DPI-phi)*cos(phi))/!DPI + t*(1.0 - 0.5*cos(phi))^2 )
    fphHapke63 = B*S
return, fphHapke63
end

epsilon=1e-4
openw,33,'hapfun.dat'
for phi=0,180-epsilon,1 do begin
printf,33,phi,BtimesS(phi*!dtor,0.1,0.6)
endfor
close,33
data=get_data('hapfun.dat')
ph=reform(data(0,*))
BS=reform(data(1,*))
plot,ph,BS,xtitle='Phase angle',ytitle='B*S H63',title='t=0.1; =0.122 (red)'
openw,33,'hapfun.dat'
for phi=0,180-epsilon,1 do begin
printf,33,phi,BtimesS(phi*!dtor,0.12,0.6)
endfor
close,33
data=get_data('hapfun.dat')
ph=reform(data(0,*))
BS=reform(data(1,*))
oplot,ph,BS,color=fsc_color('red')
end

