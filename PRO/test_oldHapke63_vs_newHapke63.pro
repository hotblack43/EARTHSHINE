FUNCTION Schonberg, phase_angle   ; scattering by a Lambertian particle ??? IS SCALING CORRECT ???
 phase_angle = abs(phase_angle)
 Pg =  (sin(phase_angle) + (!dpi-abs(phase_angle))*cos(phase_angle))/!dpi
 return, Pg
 END
 
 FUNCTION Hapke63, ssalbedo, inc_angle, scatt_angle, phase_angle
 ; Note: All angles are assumed to be radians
 w0  = ssalbedo
 mu0 = cos(inc_angle)
 mu  = cos(scatt_angle)
 t   = 0.1d
 Pg  = Schonberg(abs(phase_angle)) + (t*(1.0d - cos(abs(phase_angle)))^2)
;Pg  = Schonberg(abs(phase_angle)) + (8.0d/3.0d) * (t*(1.0d - cos(abs(phase_angle)))^2)
 g   = 0.6d
 if (phase_angle EQ 0.0d) then begin
     Bg = 1.0d
     endif else if ((phase_angle GT 0.0d) AND (phase_angle LT (!dpi/2.0d - 0.00001d))) then begin
     Bg = 2.0d - (tan(phase_angle)/(2.0d*g)) * (1.0d - exp(-g/tan(phase_angle))) * (3.0d - exp(-g/tan(phase_angle)))
     endif else if (phase_angle GE (!dpi/2.0d - 0.00001d)) then begin
     Bg = 0.0d
     endif else begin
     stop, 'ERROR in function Hapke63: invalid phase angle.'
     endelse
 M = 0.0d0
 S = 1.0d0
 if (inc_angle LE !dpi/2.0d) and (scatt_angle LE !dpi/2.0d) then begin
     BRDF = (w0/(4.0d*!dpi)) * (1.0d/(mu0+mu)) * (1.0d + Bg)*Pg
     endif else begin
     BRDF = 0.0d
     endelse
 return, BRDF
 END
 
 FUNCTION oldHapke63,hapkeG,hapket,phi,inc_angle, scatt_angle
 DRADEG = 180.0D/!DPI
 g = hapkeG
 t = hapket
 if (phi EQ 0.0D) then begin
     B = 2.0
     endif else if (phi GT 0.0D AND phi LT (!DPI/2.0-0.00001)) then begin
     B = 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi)))
     endif else if (phi GE (!DPI/2.0-0.00001)) then begin
     B = 1.0
     endif
 S = (2.0/(3*!DPI)) * ( (sin(phi) + (!DPI-phi)*cos(phi))/!DPI + t*(1.0 - 0.5*cos(phi))^2 )
 fphHapke63 = B*S
 WannJensen2=2./3./!pi*fphHapke63*(1./(1.+cos(scatt_angle)/cos(inc_angle)))
 return,WannJensen2
 end
 
 inc_angle=!pi/4.
 scatt_angle=!pi/4.
 openw,44,'data.dat'
 for phi=0.1,1.0,!pi/100. do begin
     print,phi,oldHapke63(0.6,0.1,phi,inc_angle, scatt_angle),Hapke63(1.0, inc_angle, scatt_angle, phi)
     printf,44,phi,oldHapke63(0.6,0.1,phi,inc_angle, scatt_angle),Hapke63(1.0, inc_angle, scatt_angle, phi)
     endfor
 close,44
 data=get_data('data.dat')
!P.MULTI=[0,1,2]
 plot,data(0,*),data(2,*),xtitle='Phase angle',ytitle='Old and new Hapke63'
 oplot,data(0,*),data(1,*),color=fsc_color('red')
 plot,ystyle=3,data(0,*),data(2,*)/data(1,*),xtitle='Phase angle',ytitle='Ratio '
 end
