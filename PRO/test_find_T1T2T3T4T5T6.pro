PRO get_twilight_details,jd_in,dusk_ff_start,dusk_ff_end,dawn_ff_start,dawn_ff_stop,obs_time_start,obs_time_end,moon_rising_am2,moon_setting_am2
 common place,obsname,obslon,obslat,jd_offset
 caldat,jd_in,mm,dd,yy
 ; will use find_sun.pro to return the Tmark times
 ; will use find_moon.pro to find times hwen Moon is at am=2
 ;....................................................................................
 TZ_offset=(obslon/180)*(-12.)		; This is the offset in HOURS to get the right approximate dawn/dusk
			; time, given observatory longitude. Note that 'observatory.pro' uses
			; NEGATIVE logitudes numbers for EAST longitude
 ; first dusk
 RiseSet=-1
 UTdusk=18+TZ_offset	; this is the guess for when sundown is in UT - works for Europe. Hawaii needs 12 hours more!
 if (UTdusk  lt 0) then begin
	UTdusk=UTdusk+24
	dd=dd-1
 endif
 jd_dusk_guess=julday(mm,dd,yy,UTdusk)
 ;..
 alt=-5	; this is the Tmark for start of dusk FFs
 find_sun,jd_dusk_guess,dusk_ff_start,alt,RiseSet,obsname
 ;..
 alt=-8	; this is the Tmark for end of dusk FFs
 find_sun,jd_dusk_guess,dusk_ff_end,alt,RiseSet,obsname
 ;..
 alt=-18	; this is the Tmark for start of OBS
 find_sun,jd_dusk_guess,obs_time_start,alt,RiseSet,obsname
 ;..
 alt=30	; this is the Tmark for Moon at am=2
 find_moon,jd_dusk_guess,moon_rising_am2,alt,RiseSet,obsname
 ;....................................................................................
 ; then dawn
 RiseSet=+1
 UTdawn=6+TZ_offset
 if (UTdawn lt 0) then begin
	UTdawn=UTdawn+24
	dd=dd-1
 endif
 jd_dawn_guess=julday(mm,dd+1,yy,UTdawn)
 ;---
 alt=-18	; this is the Tmark for end of OBS
 find_sun,jd_dawn_guess,obs_time_end,alt,RiseSet,obsname
 ;---
 alt=-8	; this is the Tmark for start of dawn FFs
 find_sun,jd_dawn_guess,dawn_ff_start,alt,RiseSet,obsname
 ;---
 alt=-5	; this is the Tmark for end of dawn FFs
 find_sun,jd_dawn_guess,dawn_ff_stop,alt,RiseSet,obsname
 ;..
 alt=30	; this is the Tmark for Moon at am=2
 find_moon,jd_dawn_guess,moon_setting_am2,alt,RiseSet,obsname
 ;....................................................................................
 return
 end

PRO get_t1t2t3t4t5t6,jd_in,obsname,t1,t2,t3,t4,t5,t6
; will find the values of the TIMERS for any given JD and location
get_twilight_details,jd_in,dusk_ff_start,dusk_ff_end,dawn_ff_start,dawn_ff_stop,obs_time_start,obs_time_end,moon_rising_am2,moon_setting_am2
lunar_obs_start=moon_rising_am2
lunar_obs_stop=moon_setting_am2
t1=dusk_ff_start
t2=obs_time_start
t3=lunar_obs_start
t4=lunar_obs_stop
t5=obs_time_end
t6=dawn_ff_start
return
end





;---------------
common place,obsname,obslon,obslat,jd_offset

obsname='lund'
observatory, obsname, obs
obslon= obs.longitude
obslat= obs.latitude
observatory_altitude  = obs.altitude

jd_in=julday(3,12,2011,0,0,1)
get_t1t2t3t4t5t6,jd_in,obsname,t1,t2,t3,t4,t5,t6
print,format='((a32,1x,f20.6))','Dusk FF starts:',t1
print,format='((a32,1x,f20.6))','First Extinctions can start:',t2
print,format='((a32,1x,f20.6))','Moon observations can start:',t3
print,format='((a32,1x,f20.6))','Moon observations must stop:',t4
print,format='((a32,1x,f20.6))','Second Extinctions can start:',t5
print,format='((a32,1x,f20.6))','Dawn FF Starts:',t6
end
