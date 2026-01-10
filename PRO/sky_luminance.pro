FUNCTION CIE_clear_sky_standard,chi,Z,Zs,a,b,c,d,e
 ; calculates the CIE Clear SKy Standard Luminance
 ;
 CIE_clear_sky_standard=f(chi,c,d,e)*psi(Z,a,b)/f(Zs,c,d,e)/psi(0.0,a,b)
 return, CIE_clear_sky_standard
 end
 
 
 ; Follows paper "CIE General Sky Standard Defining luminance distributions" by Darula, S., and Kittler, R.
	;
	N NOTE that this paper only gives the luminance relative to the zenith luminance
 ;
 ; Define Solar position in terms of alt,az
 
 icount=100
 loadct,39
window,0,xsize=600,ysize=700
 openw,67,'best_altitude.dat'
 for sun_zenith_dist=0.,90+15.,1.0 do begin
     sun_az=40.0
     ;
     naz=360
     nalt=90
     sky_luminance=fltarr(naz,nalt)
     sky_luminance_gradient=fltarr(naz,nalt)
     r=fltarr(naz,nalt)
     theta=fltarr(naz,nalt)
; CIE model parameters
; Type 11 or 12
     a=-1.0
     b=-0.32
     c=10.
     d=-3.0
     e=0.45
; Type 14
;    a=-1.0
;    b=-0.15
;    c=16.
;    d=-3.0
;    e=0.30
     for iaz=0,359,1 do begin	; loop over azimuth for sky elements
         for ialt=0,89,1 do begin	; loop over sky element altitude
             element_azimuth=iaz*1.0
             element_zenith_dist=90.0-ialt*1.0
             Az=abs(sun_az-element_azimuth)
             chi=acos(cos(sun_zenith_dist*!dtor)*cos(element_zenith_dist*!dtor)+sin(sun_zenith_dist*!dtor)*sin(element_zenith_dist*!dtor)*cos(Az*!dtor))/!dtor
             sky_luminance(iaz,ialt)=CIE_clear_sky_standard(chi,element_zenith_dist,sun_zenith_dist,a,b,c,d,e)
             ;
             r(iaz,ialt)=89-element_zenith_dist
             theta(iaz,ialt)=element_azimuth
             endfor	; end of altitude loop
         endfor	; end of azimuth loop
     ; make fish-eye plot of luminance
         map_set,90,0,0,/satellite,sat_p=[10000,0,0],title='CIE clear sky luminance',/isotropic
;         contour,sky_luminance,theta,r,/irregular,/overplot,charsize=2.0,/cell_fill,nlevels=101
         contour,sky_luminance,theta,r,/irregular,/overplot,charsize=2.0,nlevels=11
; find darkest point
min=min(sky_luminance,location)
print,'Min at:',theta(location),r(location),90.-sun_zenith_dist,sky_luminance(location)
printf,67,r(location),90.-sun_zenith_dist,sky_luminance(location)
plots,[theta(location),theta(location)],[r(location),r(location)],psym=7
     ; generate GIF files of the view, suitable for movie making with convert
     write_gif,strcompress('luminance_'+string(icount)+'.gif',/remove_all),tvrd()
     icount=icount+1
     endfor
	close,67
; plot 
 end
