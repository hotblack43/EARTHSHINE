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


MOONPOS, jd, ra_moon, DECmoon, dis
eq2hor, RA_moon, DECmoon, JD, alt_moon, az, ha, LAT=observatory_latitude , LON=observatory_longitude , OBSNAME='mso' , $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
SUNPOS, jd, ra_sun, DECsun
eq2hor, RA_sun, DECsun, JD, alt_sun, az, ha, LAT=observatory_latitude , LON=observatory_longitude , OBSNAME='mso' , $
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
 ; Version 1. June 2010
 ;-------------------------------------------------------------------------------------
 
 ;-------------------------------------------------------------------------------------
 ; Specify the observatory name
 ;-------------------------------------------------------------------------------------
 obsname='cfht'
 
 openw,66,'Moon_table1.dat'
 openw,67,'Moon_table2.dat'
 sunlimit=0.0
 moonlimit=30.0
 fmt='(f15.7,2(1x,f8.3))'
 for JD=double(julday(12,7,2010,12,1,0)),double(julday(1,7,2012,12,1,0)),1. do begin
     print,'------------------------------------------------------------------------'
     print,'Checking JD:',JD
     ; for that day lay out sun and moon at 1 minute steps
     openw,23,'temporary.dat'
     tstep=1./24./4.		; in days
     tstep=1./24./12.	; in days
     for xJD=JD,JD+1.0,tstep do begin
         moonphase_pth,xjd,phase_angle_M,alt_moon,alt_sun,obsname
         printf,23,format=fmt,xJD,alt_moon,alt_sun
         endfor
     close,23
     ; now look at the position of sun and moon and find rise and set times
     data=get_data('temporary.dat')
     time=reform(data(0,*))
     alt_moon=reform(data(1,*))
     alt_sun=reform(data(2,*))
     plot,time,alt_sun,psym=7,xstyle=1
     plots,[!x.crange],[sunlimit,sunlimit]
     plots,[!x.crange],[moonlimit,moonlimit]
     oplot,time,alt_moon,psym=6
     n=n_elements(time)
     fmt2='(a33,1x,f12.3,2(1x,f9.2),2(1x,i2),1x,i4,2(1x,i2),1x,f7.2)'
     stoptime=1e33
     startime=-1e33
     for k=1,n-1,1 do begin
         caldat,time(k),mm,dd,yy,hr,mi,se
         ; case of sun below limit moon rising
         if (alt_sun(k) lt sunlimit and alt_moon(k) gt moonlimit and alt_moon(k-1) le moonlimit) then begin
             print,format=fmt2, 'START: Sun down, Moon rising at: ',time(k),alt_sun(k),alt_moon(k),mm,dd,yy,hr,mi,se
             plots,[time(k),time(k)],[!Y.crange]
             startime=time(k)
             endif
         ; case of sun below limit moon setting
         if (alt_sun(k) lt sunlimit and alt_moon(k) le moonlimit and alt_moon(k-1) gt moonlimit) then begin
             print,format=fmt2, 'STOP: Sun down, Moon setting at: ',time(k),alt_sun(k),alt_moon(k),mm,dd,yy,hr,mi,se
             plots,[time(k),time(k)],[!Y.crange]
             stoptime=time(k)
             endif
         ; case of moon above limit as sun sets
         if (alt_moon(k) gt moonlimit and alt_sun(k) le sunlimit and alt_sun(k-1) gt sunlimit) then begin
             print,format=fmt2, 'START: Moon up, sun setting at: ',time(k),alt_sun(k),alt_moon(k),mm,dd,yy,hr,mi,se
             plots,[time(k),time(k)],[!Y.crange]
             startime=time(k)
             endif
         ; case of moon above limit as sun rises
         if (alt_moon(k) gt moonlimit and alt_sun(k) gt sunlimit and alt_sun(k-1) le sunlimit) then begin
             print,format=fmt2, 'STOP: Moon up, sun rising at: ',time(k),alt_sun(k),alt_moon(k),mm,dd,yy,hr,mi,se
             plots,[time(k),time(k)],[!Y.crange]
             stoptime=time(k)
             endif
         endfor
     print,stoptime-startime
     if (stoptime-startime lt 1e3) then begin
         print,'Duration : ',(stoptime-startime)*24.,' hrs.'
         printf,66,format='(1x,f15.1,2(1x,f15.7))',JD,startime,stoptime
         printf,67,format='(1x,f15.1,2(1x,f15.7))',JD,startime,stoptime
         print,format='(1x,f15.1,2(1x,f15.7))',JD,startime,stoptime
         endif
     if (stoptime-startime gt 1e3) then begin
         printf,66,format='(1x,f15.1,1x,a)',JD,' ---------       -----------'
         print,format='(1x,f15.1,1x,a)',JD,' ---------       -----------'
         endif
     endfor
 close,66	; close the master table
 close,67	; close the other master table
 ; read the master table and now make a list of start/stop for the CONTIGUOUS periods
 openw,44,'Observability_periods_'+obsname+'.dat'
 data=get_data('Moon_table2.dat')
 starting=reform(data(1,*))
 stopping=reform(data(2,*))
 n=n_elements(starting)
 ic=7123	; this is the unique observing night number
 for i=0,n-1,1 do begin
     sta=starting(i)
     ; find the first number on the stopping list AFTER sta
     diff=stopping-sta
     idx=where(diff gt 0)
     if (idx(0) ne -1) then begin
         sto=stopping(idx(0))
         print,format='(1x,i5,2(1x,f15.7))',ic,sta,sto
         printf,44,format='(1x,i5,2(1x,f15.7))',ic,sta,sto
         ic=ic+1
         endif
     endfor
 close,44
 end
