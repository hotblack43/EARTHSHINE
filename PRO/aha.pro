; Ped. [0,6
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
 
 
 PRO get_filter_offset,jd,offset
 ; calculates the offset of the Earthshine telescope ND filter or KE
 ; Uses HORIZONS input tables
 ; Output is always a positive offset, in arc seconds
 common place,obsname,obslon,obslat,jd_offset
 filename=strcompress('../HORIZONS/res_Nov2010.1year_plus_'+obsname,/remove_all)
 print,'I am assuming that you correctly wish to use the file named ',filename
 data=get_data(filename)
 jd_t=reform(data(0,*))
 diameter_t=reform(data(1,*))
 angle_t=reform(data(2,*))
 offset_t=reform(data(3,*))
 illumpct_t=reform(data(4,*))
 offset=INTERPOL(offset_t,jd_t,jd)	; degrees East of North
 R=INTERPOL(diameter_t,jd_t,jd)/2.0	; lunar disc radius in arc seconds
 ;
 if (offset le 0) then offset=R/2.
 if (offset gt 0) then begin
     alpha=asin(abs(offset)/R)	; in radians
     offset=R*cos(alpha/2.)		; in arc seconds
     endif
 return
 end
 
 PRO get_dusk_dawn,jd_start,dusk_ff_start,dusk_ff_stop,dawn_ff_start,dawn_ff_stop, $
 obs_time_start,obs_time_end,cuspangle,cuspoffset,illuminated_fraction,proto_file_names,$
 proto_sheet_names,t1,t2,t3,t4,t5,t6
 ;------------------------------------------------------
 dusk_ff_start=dblarr(28)
 dusk_ff_stop=dblarr(28)
 dawn_ff_start=dblarr(28)
 dawn_ff_stop=dblarr(28)
 obs_time_start=dblarr(28)
 obs_time_end=dblarr(28)
 cuspangle=dblarr(28)
 cuspoffset=dblarr(28)
 illuminated_fraction=dblarr(28)
 t1=fltarr(28)
 t2=fltarr(28)
 t3=fltarr(28)
 t4=fltarr(28)
 t5=fltarr(28)
 t6=fltarr(28)
 ;-----------------------------------------------------------------------------------
 ; here are the values that the user can change, with experience
 ; Note that Tmark stands in for concepts like sundown and sunup
 ffstart_relative_Tmarkdusk=0.0d0	; minutes relative to Tmarkdusk to start dusk ffs - note sign is used
 ffstart_relative_Tmarkdawn=0.0d0	; minutes relative to Tmarkdawn to start dawn ffs - note sign is used
 ;-----------------------------------------------------------------------------------
 ; the following should NOT be changed
 ffstart_relative_Tmarkdusk=ffstart_relative_Tmarkdusk/60./24.	; converted to days
 ffstart_relative_Tmarkdawn=ffstart_relative_Tmarkdawn/60./24.   ; converted to days
 ;-----------------------------------------------------------------------------------
 ;
 for i=0,27,1 do begin
     caldat,jd_start+i,mm,dd,yy
     doy=jd_start+i-julday(1,1,yy)
     get_twilight_details,jd_start+i,dusk_ff_start_val,dusk_ff_end_val,dawn_ff_start_val,dawn_ff_stop_val,obs_time_start_val,obs_time_end_val
     ; Dusk
     dusk_ff_start(i)=dusk_ff_start_val+ffstart_relative_Tmarkdusk
     dusk_ff_stop(i)=dusk_ff_end_val
     obs_time_start(i)=obs_time_start_val
     ; Dawn
     obs_time_end(i)=obs_time_end_val
     dawn_ff_start(i)=dawn_ff_start_val+ffstart_relative_Tmarkdawn
     dawn_ff_stop(i)=dawn_ff_stop_val
     ; cusp angle
     cuspangle(i)=cusp_angle(jd_start+i,obsname)/!dtor
     get_filter_offset,jd_start+i,offset
     cuspoffset(i)=offset	; always positive
     ; illuminated fraction
     mphase,jd_start+i,k
     illuminated_fraction(i)=k
     t1(i)=0.0
     t2(i)=0.0
     t3(i)=0.0
     t4(i)=0.0
     t5(i)=0.0
     t6(i)=0.0
     endfor
 ; Blank out the values corresponding to bad Moon phase
 if_blankout=1
 if (if_blankout eq 1) then begin
     idx=where(illuminated_fraction lt 0.2 or illuminated_fraction gt 0.8)
     ;dusk_ff_start(idx)=0.0
     ;dusk_ff_stop(idx)=0.0
     ;dawn_ff_start(idx)=0.0
     ;dawn_ff_stop(idx)=0.0
     ;obs_time_start(idx)=0.0
     ;obs_time_end(idx)=0.0
     cuspangle(idx)=0.0
     cuspoffset(idx)=0.0
     proto_file_names(idx)='SPECIAL.txt'
     ;proto_sheet_names(idx)='SPECIAL'
     endif
 return
 end
 
 ;----------------------------------------------------------------------------------------------------
 ; Version 7 of the code to set up the 'System Data' Table. 
 ; Like Version 6, but now uses the 6 timers allowed by the new operating system for the telescope.
 ;----------------------------------------------------------------------------------------------------
 common place,obsname,obslon,obslat,jd_offset
 read,ianswer,prompt='Are you sure that the input data tables are for the required observatory location? (1/0)'
 if (ianswer ne 1) then begin
     print,'If you are not sure, go the ../HORIZONS directory and run the code there for the CORRECT location!'
     stop
     endif
 obsname='dummy'
 get_lun,oop & openr,oop,'obsname.txt' & readf,oop,obsname & close,oop & free_lun,oop
 observatory, obsname, obs
 obslon= obs.longitude
 obslat= obs.latitude
 observatory_altitude  = obs.altitude
 row_headers=['JULIAN-DATE','PROTO-FILE','CUSP-ANGLE','CUSP-OFFSET','STARTTIME1','STARTTIME2','STARTTIME3','STARTTIME4','STARTTIME5','STARTTIME6']
 proto_file_names=['LD01.txt','LD02.txt','LD03.txt','LD04.txt','LD05.txt','LD06.txt','LD07.txt','LD08.txt','LD09.txt','LD10.txt','LD11.txt',$
 'LD12.txt','LD13.txt','LD14.txt','LD15.txt','LD16.txt','LD17.txt','LD18.txt','LD19.txt','LD20.txt','LD21.txt','LD22.txt','LD23.txt',$
 'LD24.txt','LD25.txt','LD26.txt','LD27.txt','LD28.txt']
 ;----------------------------------------------------------------------------------------------------
 ndays=28	; number of days to print table for
 if (ndays gt 28) then stop	; only do one lunar month att he time
 line=strarr(ndays+1,10)
 ;----------------------------------------------------------------------------------------------------
 get_lun,w
 openw,w,'System_Data_Table.csv'
 ;----------------------------------------------------------------------------------------------------
 ; you may edit this line:
 jd_start=long(julday(1,1,2011,12,1,0))
 ;..............................
 ; but not these
 caldat,jd_start,mm,dd,yy
 jd_offset=long(julday(12,31,yy-1))
 get_dusk_dawn,jd_start,dusk_ff_start,dusk_ff_stop,dawn_ff_start,$
 dawn_ff_stop,obs_time_start,obs_time_end,cuspangle,cuspoffset,$
 illuminated_fraction,proto_file_names,proto_sheet_names,$
 timer1,timer2,timer3,timer4,timer5,timer6
 fmt1='(a)'
 fmt1b='(28(a,a))'
 fmt2='(f20.5)'
 fmt3='(f6.1)'
 for irow=0,10-1,1 do begin
     line(0,irow)=row_headers(irow)
     if (irow eq 0) then begin
         for k=1,ndays,1 do line(k,irow)=string(long(dusk_ff_start(k-1)))
         endif
     if (irow eq 1) then begin
         for k=1,ndays,1 do line(k,irow)=proto_file_names(k-1)
         endif
     if (irow eq 2) then begin
         for k=1,ndays,1 do line(k,irow)=string(cuspangle(k-1),format=fmt3)
         endif
     if (irow eq 3) then begin
         for k=1,ndays,1 do line(k,irow)=string(cuspoffset(k-1),format=fmt3)
         endif
     if (irow eq 4) then begin
         for k=1,ndays,1 do line(k,irow)=string(timer1(k-1),format=fmt3)
         endif
     if (irow eq 5) then begin
         for k=1,ndays,1 do line(k,irow)=string(timer2(k-1),format=fmt3)
         endif
     if (irow eq 6) then begin
         for k=1,ndays,1 do line(k,irow)=string(timer3(k-1),format=fmt3)
         endif
     if (irow eq 7) then begin
         for k=1,ndays,1 do line(k,irow)=string(timer4(k-1),format=fmt3)
         endif
     if (irow eq 8) then begin
         for k=1,ndays,1 do line(k,irow)=string(timer5(k-1),format=fmt3)
         endif
     if (irow eq 9) then begin
         for k=1,ndays,1 do line(k,irow)=string(timer6(k-1),format=fmt3)
         endif
     endfor
 ;
 pointer=[0,1,3,2,4,5,6,7,8,9]
 for iptr=0,10-1,1 do begin
     irow=pointer(iptr)
     line_str=line(0,irow)+','
     for icol=1,ndays-1,1 do begin
         line_str=line_str+line(icol,irow)+','
         endfor
     line_str=line_str+line(ndays,irow)
     print,format=fmt1,strcompress(line_str,/remove_all)
     printf,w,format=fmt1,strcompress(line_str,/remove_all)
     endfor
 close,w
 free_lun,w
 end
