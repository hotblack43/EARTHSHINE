PRO get_moon_times,alt_lim,jdstart,jdend,obsstart,obsstop
 ; will find times when the Moon sets and rises past the indicated altitude
 obsstop=-911
 obsstart=-911
 jdstep=1./24./60.	; one-minute steps
 ; first of all start at the beginning and 'walk' until a obsstart is detected
 ; use steps 1 minute long for local derivatives
 jdstep=1.0d0/24.0d0/60.0d0
 for ijd=jdstart,jdend,jdstep do begin
     get_moon_pos_direct,ijd+jdstep,alt_moon_future
     get_moon_pos_direct,ijd-jdstep,alt_moon_past
     if (alt_moon_future gt alt_lim and alt_moon_past le alt_lim) then obsstart=ijd
     if (obsstart ne -911) then goto, outofloop
     endfor
 outofloop:
 jd1=jdstart
 if (obsstart gt 0) then jd1=obsstart
 for ijd=jdstart,jdend,jdstep do begin
     get_moon_pos_direct,ijd+jdstep,alt_moon_future
     get_moon_pos_direct,ijd-jdstep,alt_moon_past
     if (alt_moon_future le alt_lim and alt_moon_past gt alt_lim) then obsstop=ijd
     if (obsstop ne -911) then goto, outofloop2
     endfor
 outofloop2:
 return
 end
 
 PRO get_sun_times,alt_lim,jdstart,jdend,obsstart,obsstop
 ; will find times when the Sun sets and rises pastthe indicated altitude
 obsstop=-911
 obsstart=-911
 jdstep=1./24./60.	; one-minute steps
 ; first of all start at the beginning and 'walk' until a obsstart is detected
 ; use steps 1 minute long for local derivatives
 jdstep=1.0d0/24.0d0/60.0d0
 for ijd=jdstart,jdend-jdstep,jdstep do begin
     get_sun_pos_direct,ijd+jdstep,alt_sun_future
     get_sun_pos_direct,ijd-jdstep,alt_sun_past
     if (alt_sun_future lt alt_lim and alt_sun_past ge alt_lim) then obsstart=ijd
     if (obsstart ne -911) then goto, outofloop
     endfor
 print,'It is bad that you reached this point: stopping.'
 stop
 outofloop:
 for ijd=obsstart,jdend-jdstep,jdstep do begin
     get_sun_pos_direct,ijd+jdstep,alt_sun_future
     get_sun_pos_direct,ijd-jdstep,alt_sun_past
     if (alt_sun_future ge alt_lim and alt_sun_past lt alt_lim) then obsstop=ijd
     if (obsstop ne -911) then goto, outofloop2
     endfor
 stop
 outofloop2:
 return
 end
 
 PRO get_moon_pos_direct,jd,alt_moon
 common obs,obsname
 MOONPOS, jd, ra_moon, DEmoon
 eq2hor, ra_moon, DEmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
 return
 end
 
 PRO get_sun_pos_direct,jd,alt_sun
 common obs,obsname
 SUNPOS, jd, ra_sun, DEsun
 eq2hor, ra_sun, DEsun, jd, alt_sun, az_sun, ha_sun,  OBSNAME=obsname
 return
 end
 
 
 ; Will print all the times t1,t2,..,t6
 ; and the 'type' of night
 common obs,obsname
 common lims,sun_lim,am_lim
 mostring=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
 sun_lim=-5
 am_lim=2
 obsname='lapalma'
 obsname='dmi'
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 ; note the minus sign - lon follows observatory.pro and -lon what zensun expects (USA is neg lon)
 lon=-obs_struct.longitude
 print,'lon,lat: ',lon,lat
 if (obsname ne 'mlo') then begin
 jd1=double(julday(3,1,2011,12,0,1))
 jd2=double(julday(4,1,2012,12,0,1))
 endif
 if (obsname eq 'mlo') then begin
 jd1=double(julday(3,1,2011,0,0,1))
 jd2=double(julday(3,1,2012,0,0,1))
 endif
 openw,5,strcompress(obsname+'_SunMoontimes.dat',/remove_all)
 printf,5,"  Sun under  0    Sun under -8    Sun under -18   Sund under -18  Sun under -8    Sun under  0   Moon over 30    Moon over 30   Type"
 for jd=jd1,jd2,1.0d0 do begin
     ;--------
     jdstart=jd-.98
     jdend=jd+.98
     alt_lim=0.0d0
     get_sun_times,alt_lim,jdstart,jdend,dusk_start,dawn_end
     ;--------
     alt_lim=-8.0d0
     get_sun_times,alt_lim,dusk_start,dawn_end,dusk_end,dawn_start
     ;--------
     alt_lim=-18.0d0
     get_sun_times,alt_lim,dusk_end,dawn_start,obsstart,obsstop
     ;--------
     alt_lim=30.0d0
     alt_lim=0.0d0	; this value seems necessary to avoid STOP elsewhere
     get_moon_times,alt_lim,obsstart,obsstop,moonriseam2,moonsetam2
     ;get_moon_times,alt_lim,jdstart,jdend,moonriseam2,moonsetam2
     ;--------
     print,format='(a,2(1x,f20.6))','Dusk start stop:',dusk_start,dusk_end
     print,format='(a,2(1x,f20.6))','Obs start stop :',obsstart,obsstop
     print,format='(a,2(1x,f20.6))','Dawn start stop:',dawn_start,dawn_end
     print,format='(a,2(1x,f20.6))','Moon upam2 downam2:',moonriseam2,moonsetam2
     type_str='4'
     plenty=2.0/24.	; (days) - longer than this and there is time for FFs during the moon-good time
     ; first test if rise time for moon is less than set time
     if (moonriseam2 ne -911 and moonsetam2 ne -911) then begin
; this is two types - up first then down AND down first up later
	type_str='1a'
        if (moonsetam2 lt moonriseam2) then type_str='1b'
     endif else if (moonriseam2 eq -911 and moonsetam2 ne -911)  then begin
	type_str='2'
     endif else if (moonriseam2 ne -911 and moonsetam2 eq -911)  then begin
	type_str='3'
     endif else if (moonriseam2 eq -911 and moonsetam2 eq -911) then  begin
; this type always up or always down
	type_str='4a'	; down all night
	get_moon_pos_direct,(obsstart+obsstop)/2.0,alt_moon
       	if (alt_moon gt 30.0) then type_str='4b' 
     endif
     print,format='(8(1x,f15.6),1x,a)',dusk_start,dusk_end,obsstart,obsstop,dawn_start,dawn_end,moonriseam2,moonsetam2,type_str
     print,'----------------------------------------------------'
     printf,5,format='(8(1x,f15.6),1x,a)',dusk_start,dusk_end,obsstart,obsstop,dawn_start,dawn_end,moonriseam2,moonsetam2,type_str
     endfor
 close,5
 end
 
