PRO get_twilight_details,jd_in,dusk_ff_start,dusk_ff_end,dawn_ff_start,dawn_ff_stop,obs_time_start,obs_time_end
 common place,obsname,obslon,obslat,jd_offset
 caldat,jd_in,mm,dd,yy
 ; will use find_sun.pro to return the Tmark times
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
 ;....................................................................................
 return
 end
