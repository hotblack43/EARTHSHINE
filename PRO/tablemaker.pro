PRO moonphase_pth,jd,phase_angle_M,alt_moon,alt_sun,obsname
 ;-----------------------------------------------------------------------
 ; Set various constants.
 ;-----------------------------------------------------------------------
RADEG  = 180.0/!PI
DRADEG = 180.0D/!DPI
AU = 149.6d+6       ; mean Sun-Earth distance     [km]
Rearth = 6365.0D    ; Earth radius                [km]
Rmoon = 1737.4D     ; Moon radius                 [km]
Dse = AU            ; default Sun-Earth distance  [km]
Dem = 384400.0D     ; default Earth-Moon distance [km]


 observatory, obsname, obs
 observatory_longitude = obs.longitude
 observatory_latitude  = obs.latitude
 observatory_altitude  = obs.altitude
 
;print,'Lon,lat,altitude,name of observatory : ',obs.longitude,obs.latitude,obs.altitude,obsname
 
 MOONPOS, jd, ra_moon, DECmoon, dis
 eq2hor, RA_moon, DECmoon, JD, alt_moon, az, ha, LAT=observatory_latitude , LON=observatory_longitude , OBSNAME=obsname , $
 PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
 SUNPOS, jd, ra_sun, DECsun
 eq2hor, RA_sun, DECsun, JD, alt_sun, az, ha, LAT=observatory_latitude , LON=observatory_longitude , OBSNAME=obsname , $
 PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
 
 RAdiff = ra_moon - ra_sun
 sign = +1
 if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
 phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
 phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
 return
 end
 
 ;-------------------------------------------------------------------------------------
 ; Code to set up the starting and ending time (in JD format) for periods of lunar observability
 ; Version 2. June 2010
 ;-------------------------------------------------------------------------------------
 
 ;-------------------------------------------------------------------------------------
 ; Specify the observatory name
 ;-------------------------------------------------------------------------------------
 obsname='cfht'
 
 sunlimit=0.0
 moonlimit=30.0
 fmt='(f15.7,3(1x,f8.3))'
 tstep=1./24./4.		; in days
 tstep=1./24./12./5.	; in days
 openw,23,'altitudes_sun_moon.dat'
 for JD=double(julday(12,7,2010,12,1,0)),double(julday(1,7,2013,12,1,0)),tstep do begin
     moonphase_pth,jd,phase_angle_M,alt_moon,alt_sun,obsname
     printf,23,format=fmt,JD,alt_moon,alt_sun,phase_angle_M
     endfor
 close,23
 data=get_data('altitudes_sun_moon.dat')
 xJD=reform(data(0,*))
 malt=reform(data(1,*))
 salt=reform(data(2,*))
 phase=reform(data(3,*))
 moon_deriv=DERIV(xJD,malt)	& moon_deriv=moon_deriv/(abs(moon_deriv))
 sun_deriv=DERIV(xJD,salt)	& sun_deriv=sun_deriv/(abs(sun_deriv))
 n=n_elements(xJD)
 fmt2='(a30,1x,f19.7,4(1x,f9.3))'
; 
 moon_good=(malt gt moonlimit)
 sun_good=(salt lt sunlimit)
 obs_good=moon_good*sun_good	; observe if SUn is down and Moon is up
 openw,55,'starts.dat'
 openw,56,'stops.dat'
 for i=0L,n-2,1 do begin
 if (obs_good(i) eq 0 and obs_good(i+1) gt 0) then begin
	print,'START:',xJD(i),malt(i),salt(i),moon_deriv(i),sun_deriv(i)
 	printf,55,format='(f19.7,1x,f9.3)',xJD(i),phase(i)
 endif
 if (obs_good(i) gt 0 and obs_good(i+1) eq 0) then begin
	print,'STOP:',xJD(i),malt(i),salt(i),moon_deriv(i),sun_deriv(i)
 	printf,56,format='(f19.7,1x,f9.3)',xJD(i),phase(i)
 endif
 endfor
 close,55
 close,56
 dummy=get_data('starts.dat')
 sta=reform(dummy(0,*))
 sta_ph=reform(dummy(1,*))
 dummy=get_data('stops.dat')
 sto=reform(dummy(0,*))
 sto_ph=reform(dummy(1,*))
 n=n_elements(sta)
 openw,84,'Start_Stop_times.dat'
 for k=0,n-1,1 do begin
	diff=sto-sta(k)
   	idx=where(diff gt 0)
        if (idx(0) ne -1) then begin
	print,sta(k),sto(idx(0))
	printf,84,format='(2(1x,f19.7),2(1x,f9.3))',sta(k),sto(idx(0)),sta_ph(k),sto_ph(idx(0))
	endif
 endfor
 close,84
 end
