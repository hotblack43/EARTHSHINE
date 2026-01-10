FUNCTION CIE_clear_sky_standard,chi,Z,Zs,a,b,c,d,e
 ; calculates the CIE Clear SKy Standard Luminance
 ;
 CIE_clear_sky_standard=f(chi,c,d,e)*psi(Z,a,b)/f(Zs,c,d,e)/psi(0.0,a,b)
 return, CIE_clear_sky_standard
 end
 
 FUNCTION sky_gradient,element_zenith_dist,element_azimuth,sun_zenith_dist,sun_az,a,b,c,d,e
 del=0.5	; degrees
 ; Set up Central value for 'Lum'
 Az=abs(sun_az-element_azimuth)
 chi=acos(cos(sun_zenith_dist*!dtor)*cos(element_zenith_dist*!dtor)+sin(sun_zenith_dist*!dtor)*sin(element_zenith_dist*!dtor)*cos(Az*!dtor))/!dtor
 Lum=CIE_clear_sky_standard(chi,element_zenith_dist,sun_zenith_dist,a,b,c,d,e)
 ; Set up for East
 Az=abs(sun_az-(element_azimuth+del))
 chi=acos(cos(sun_zenith_dist*!dtor)*cos(element_zenith_dist*!dtor)+sin(sun_zenith_dist*!dtor)*sin(element_zenith_dist*!dtor)*cos(Az*!dtor))/!dtor
 lum_E=CIE_clear_sky_standard(chi,element_zenith_dist,sun_zenith_dist,a,b,c,d,e)
 ; Set up for West
 Az=abs(sun_az-(element_azimuth-del))
 chi=acos(cos(sun_zenith_dist*!dtor)*cos(element_zenith_dist*!dtor)+sin(sun_zenith_dist*!dtor)*sin(element_zenith_dist*!dtor)*cos(Az*!dtor))/!dtor
 lum_W=CIE_clear_sky_standard(chi,element_zenith_dist,sun_zenith_dist,a,b,c,d,e)
 ; Set up for North
 Az=abs(sun_az-element_azimuth)
 chi=acos(cos(sun_zenith_dist*!dtor)*cos((element_zenith_dist+del)*!dtor)+sin(sun_zenith_dist*!dtor)*sin((element_zenith_dist+del)*!dtor)*cos(Az*!dtor))/!dtor
 lum_N=CIE_clear_sky_standard(chi,(element_zenith_dist+del),sun_zenith_dist,a,b,c,d,e)
 ; Set up for SOuth
 Az=abs(sun_az-element_azimuth)
 chi=acos(cos(sun_zenith_dist*!dtor)*cos((element_zenith_dist-del)*!dtor)+sin(sun_zenith_dist*!dtor)*sin((element_zenith_dist-del)*!dtor)*cos(Az*!dtor))/!dtor
 lum_S=CIE_clear_sky_standard(chi,(element_zenith_dist-del),sun_zenith_dist,a,b,c,d,e)
 
 ; get the relative gradient
 sky_gradient=sqrt(((lum_E-Lum_W)/Lum)^2+((lum_N-Lum_S)/Lum)^2)
 return,sky_gradient
 end
 
 
 ; Follows paper "CIE General Sky Standard Defining luminance distributions" by Darula, S., and Kittler, R.
 ;
 ; Define Solar position in terms of alt,az
 
 icount=100
 loadct,39
 window,0,xsize=400,ysize=400
 openw,67,'best_altitude.dat'
 for sun_zenith_dist=75.,95.,.33 do begin
     sun_az=40.0
     ;
     naz=360
     nalt=90
     sky_luminance=fltarr(naz,nalt)
     sky_luminance_gradient=fltarr(naz,nalt)
     r=fltarr(naz,nalt)
     theta=fltarr(naz,nalt)
     ; CIE model parameters
     ; Type 14
     a=-1.0
     b=-0.15
     c=16.
     d=-3.0
     e=0.30
     ; Type 11 or 12
     a=-1.0
     b=-0.32
     c=10.
     d=-3.0
     e=0.45
     for iaz=0,359,1 do begin	; loop over azimuth for sky elements
         for ialt=0,89,1 do begin	; loop over sky element altitude
             element_azimuth=iaz*1.0
             element_zenith_dist=90.0-ialt*1.0
             Az=abs(sun_az-element_azimuth)
             chi=acos(cos(sun_zenith_dist*!dtor)*cos(element_zenith_dist*!dtor)+sin(sun_zenith_dist*!dtor)*sin(element_zenith_dist*!dtor)*cos(Az*!dtor))/!dtor
             sky_luminance(iaz,ialt)=CIE_clear_sky_standard(chi,element_zenith_dist,sun_zenith_dist,a,b,c,d,e)
             sky_luminance_gradient(iaz,ialt)=sky_gradient(element_zenith_dist,element_azimuth,sun_zenith_dist,sun_az,a,b,c,d,e) 
             ;
             r(iaz,ialt)=89-element_zenith_dist
             theta(iaz,ialt)=element_azimuth
             endfor	; end of altitude loop
         endfor	; end of azimuth loop
;    contour,alog10(sky_luminance),theta,r,/irregular,/downhill,nlevels=31,xstyle=1,ystyle=1,title='luminance',xtitle='Azimuth',ytitle='Altitude'
;    ; plot the position of the point with minimum luminance
;    mx = MIN(sky_luminance, location)  
;    ind = ARRAY_INDICES(sky_luminance, location)  
;    azpointer=ind[0]
;    altpointer=ind[1]
;    plots,[theta(location),theta(location)],[r(location),r(location)],psym=6
;    contour,sky_luminance_gradient*100.0,theta,r,/irregular,/downhill,levels=[1e-2,1e-1,1],$
;    xstyle=1,yrange=[70,90],title='relative luminance gradient [% per degrees]',xtitle='Azimuth',ytitle='Altitude'
;    ; plot the point with minimum gradient
;    mx = MIN(sky_luminance_gradient, location)
;    ind = ARRAY_INDICES(sky_luminance_gradient, location)
;    azpointer=ind[0]
;    altpointer=ind[1]
;    plots,[theta(location),theta(location)],[r(location),r(location)],psym=5
     !P.MULTI=[0,1,2]
     !P.charsize=2
     ; print output
     ; make fish-eye plot of luminance
         map_set,42,12,0,/satellite,sat_p=[12,0,0],title='CIE clear sky luminance',/isotropic
         contour,sky_luminance,theta,r,/irregular,/overplot,charsize=2.0,/cell_fill,nlevels=101
     ; make fish-eye plot of sky gradient
         map_set,42,12,0,/satellite,sat_p=[12,0,0],title='relative luminance gradient',/isotropic,/advance
         contour,sky_luminance_gradient,theta,r,/irregular,/overplot,charsize=2.0,/cell_fill,nlevels=101
     ; generate GIF files of the view, suitable for movie making with convert
     write_gif,strcompress('luminance_'+string(icount)+'.gif',/remove_all),tvrd()
     icount=icount+1
     endfor
 close,67
 end
