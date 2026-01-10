 FUNCTION hapke63,phi_in,g
; phi is the Moon phase in radians
; g is the 'sharpness' factor - betwen 0.4 to 0.8
 n=n_elements(phi_in)
 for i=0,n-1,1 do begin
 phi=phi_in(i)
    if (phi EQ 0.0D) then begin
      if (i eq 0) then B = 2.0
      if (i gt 0) then B = [B,2.0]
    endif else if (phi GT 0.0D AND phi LT (!DPI/2.0-0.00001)) then begin
      if (i eq 0) then  B = 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi)))
      if (i gt 0) then  B = [B, 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi)))]
    endif else if (phi GE (!DPI/2.0-0.00001)) then begin
      if (i eq 0) then  B = 1.0
      if (i gt 0) then  B = [B,1.0]
    endif
 endfor
 return,b
 end
 
 ic=0
 !P.CHARSIZE=2
	!P.CHARTHICK=2
	!X.THICK=2
	!Y.THICK=2
	!P.THICK=2
 phi=findgen(360)*!dtor
 for g=0.4,0.8,0.1 do  begin
 if (ic eq 0) then plot_oi,xstyle=3,ystyle=3,phi/!dtor,hapke63(phi,g),xtitle='Lunar phase angle',ytitle='BDRF from Hapke 1963',xrange=[0.1,360]
 if (ic gt 0) then oplot,phi/!dtor,hapke63(phi,g)
 ic=ic+1
 endfor
 end
