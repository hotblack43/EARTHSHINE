FUNCTION HAPKE_B,phi,g
; 1963 Hapke B retrodirective function (Wann-Jensen eq. 3).
; phi is in RADIANS
      B = 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi)))
 idx=where(phi eq 0)
 if (idx(0) ne -1) then B(idx)=2.0
 idx=where(phi GE (!DPI/2.0-0.00001))
 if (idx(0) ne -1) then B(idx)=1.0
;
;    if (phi EQ 0.0D) then begin
;      B = 2.0
;   endif else if (phi GT 0.0D AND phi LT (!DPI/2.0-0.00001)) then begin
;     B = 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi)))
;   endif else if (phi GE (!DPI/2.0-0.00001)) then begin
;     B = 1.0
;   endif
return,b
end


!P.CHARSIZE=2
!P.THICK=2
!X.THICK=2
!Y.THICK=2
g=0.6
phi=1.0+findgen(359.0) & phi=[0.001,0.01,0.1,0.2,0.4,0.6,0.8,phi]
phi=phi*!dtor
plot_oi,phi/!dtor,HAPKE_B(phi,g),xtitle='Phase angle',ytitle='HAPKE63 B retrodirective function',xrange=[0.1,100],ystyle=3,title='g=0.4 (green), 0.6, 0.8 (red)'
g=0.8
oplot,phi/!dtor,HAPKE_B(phi,g),color=fsc_color('red')
g=0.4
oplot,phi/!dtor,HAPKE_B(phi,g),color=fsc_color('green')
end
