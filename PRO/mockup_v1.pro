PRO ephemeris,jd_in
; Routine that calculates all ephemeris information required
; INPUT			: jd_in - the time in Julian date format
; OUTPUT	: all output is via common block "ephemeris_info"
;----------------------------------------------------------------------------
common ephemeris_info,jd,mm,dd,yy,hr,minute,sec,ra_moon,decl_moon, $
ra_sun,decl_sun, alt_moon,az_moon,alt_sun,az_sun, moon_phase,		$
moon_fraction_illuminated,cusp_angle
jd=jd_in
caldat,jd,mm,dd,yy,hr,minute,sec
return
end

PRO check_weather, weather_OK
; Routine to check if the Weather is OK (1) or not (0) for observation
weather_OK=0
return
end

PRO decide_if_observe,UTC_julian,old_task_code,new_task_code,go_indicator
; Routine to decide what sort of observation is in order on the basis of the time
; and information about previously performed task(s)
; task codes: (preliminary example...!)
;	0	-	have just started, do the right thing according to time!
;	1	-	do sky flats
;	2	-	do dark frame
;	3	-	do Moon observations
;	4	-	do 'image flat fielding' (e.g. Chae's method)
;....................................................................................
common ephemeris_info,jd,mm,dd,yy,hr,minute,sec,ra_moon,decl_moon, $
ra_sun,decl_sun, alt_moon,az_moon,alt_sun,az_sun, moon_phase,		$
moon_fraction_illuminated,cusp_angle
;....................................................................................

ephemeris,UTC_julian	; get the ephemeris details refreshed


; a lot of code here ....

new_task_code=3
go_indicator=1
return
end

PRO check_go_indicator_wrt_UTC,UTC_julian,go_indicator
; On the basis of the time ONLY  this routine decides if
go_indicator=1
return
end

PRO check_ALL_indicators_are_GO,UTC_julian,go_indicator
go_indicator=1
; First check if the weather is OK for observations
check_weather, weather_OK
if (weather_OK ne 1) then begin
	go_indicator=0
	return
endif
; So weather is OK, now check the time
check_go_indicator_wrt_UTC,UTC_julian,time_OK,go_indicator
if (time_OK ne 1) then begin
	go_indicator=0
	return
endif
return
end

PRO Go_park
; commands for the hardware to park the telescope and do whatever housekeeping
; is required, e.g. telling other systems what to do.
return
end

PRO get_sky_flats,UTC_julian
return
end

PRO get_dark_frames,science_exp_time
return
end

PRO get_Moon_image,science_exp_time
science_exp_time=1.0
return
end

PRO get_images_for_Chae
return
end

;==================================================
; STANDARD MODE main routine
;==================================================
common ephemeris_info,jd,mm,dd,yy,hr,minute,sec,ra_moon,decl_moon, $
ra_sun,decl_sun, alt_moon,az_moon,alt_sun,az_sun, moon_phase,		$
moon_fraction_illuminated,cusp_angle
;..............................................................................................................
go_indicator=1
old_task_code=0	; i.e. start off without having had any previous tasks since startup
;
while (go_indicator eq 1) do begin	; main loop start
UTC_julian=systime(/julian,/UTC)	; get the current UTC time in Julian day format
;
; Perform check on weather and the time
check_ALL_indicators_are_GO,UTC_julian,go_indicator
; Decide if observations are in order on basis of time
decide_if_observe,UTC_julian,old_task_code,new_task_code,go_indicator
if (new_task_code eq 1) then get_sky_flats,UTC_julian
if (new_task_code eq 2) then get_dark_frames,science_exp_time
if (new_task_code eq 3) then get_Moon_image,science_exp_time
if (new_task_code eq 4) then get_images_for_Chae

;	1	-	do sky flats
;	2	-	do dark frame
;	3	-	do Moon observations
;	4	-	do 'image flat fielding' (e.g. Chae's method)
;
old_task_code=new_task_code	; ready to loop back
endwhile	; end of main loop
print,'Main loop exited, go_indicator ne 1!'
Go_park	; go and park the telescope and stop looping
end