FUNCTION get_exptime,duskdawnflag,timesinceFFstart,filterNumber,t0
 ; estimate the correct exposure time in seconds given info on the filter and the time
 ; This is the order of the color filters : B,V,VE1,VE2,Ircut,None
 ;
 factor=get_data('SETUP/exposure_factors')
 k=0.091	; sky-darkening factor (See Tyson & Gal paper)
 tau=1.0    ; twilight scale factor	(See Tyson & Gal paper)
 ; First work out the DUSK case
 if (duskdawnflag eq 2) then begin
     time=timesinceFFstart	; minutes 
     a=10^(k/tau)
     exposuretime=t0*a^(time)	; in seconds since t0 is in seconds
     exptime=exposuretime*factor(filterNumber-1)	; in seconds
     endif
 ; Then do the dawn case
 if (duskdawnflag eq 1) then begin
     time=timesinceFFstart*24.0d0*60.0d0	; minutes 
     a=10^(k/tau)
     exposuretime=t0*a^(-time)	; in seconds since t0 is in seconds
     exptime=exposuretime*factor(filterNumber-1)	; in seconds
     endif
 return,exptime
 end
 PRO setupaFFscript,duskdawn
 ; WIll set up a Flat Field script for use
 ; with 'Fake time' 
 ; Script writes out protocol command lines suitable
 ; for a dawn or dusk situation
 FILTERNAME=['B','V','VE1','VE2','IRCUT']
 openw,44,'MIDDLE_PART'
 if (duskdawn eq 2) then begin
     print,'Will set up a DUSK FF script'
     read,exp0,prompt='What is the first (smallest) exposure time to consider?'
     duration=35	; minutes
     expired_time=0	; minutes
     nfilters=5
     timetochangefilter=20.	; seconds
     while (expired_time le duration) do begin
 	     printf,44,strcompress('WARMSHUTTER,,,,,,,,',/remove_all)
         for ifilter=1,nfilters,1 do begin
             t=get_exptime(duskdawn,expired_time,ifilter,exp0)	; in seconds
; account for two exposures and two file-saves and time to change filter
             expired_time=expired_time+3.*(t+0.3)/60.+timetochangefilter/60.	; minutes
             print,ifilter,expired_time,' minutes ',t,' s.'
             printf,44,strcompress('SETFILTERCOLORDENSITY,'+FILTERNAME(ifilter-1)+',AIR,,,,,,,',/remove_all)
             printf,44,strcompress('SETFOCUSPOSITION,'+FILTERNAME(ifilter-1)+'_AIR_SKE,,,,,,,,',/remove_all)
;	     printf,44,strcompress('WARMSHUTTER,,,,,,,,',/remove_all)
             printf,44,strcompress('SHOOTSINGLES,'+string(t,format='(f6.2)')+',1,512,512,DUSKSKYFLAT_'+FILTERNAME(ifilter-1)+',,,,',/remove_all)

; extra lines to use the ADJUST feature
             printf,44,strcompress('ADJUST-EXP-MEDIAN,,,,',/remove_all)
	     printf,44,strcompress('SHOOTSINGLES-RCYC-1,1,1,512,512,DUSKSKYFLAT_'+FILTERNAME(ifilter-1)+'_RCYC_AIR,,,,',/remove_all)


             printf,44,strcompress('SHOOTDARKFRAME,'+string(t,format='(f6.2)')+',1,512,512,DARK,,,,',/remove_all)
	if (expired_time gt duration) then print,'--------DURATION EXPIRED-----------'
             end	; end of ifilter loop
         endwhile
     endif
 if (duskdawn eq 1) then begin
;---------------------
     print,'Will set up a DAWN FF script'
     read,exp0,prompt='What is the first (longest) exposure time to consider?'
     duration=30	; minutes
     expired_time=0	; minutes
     nfilters=5
     timetochangefilter=20.	; seconds
     while (expired_time le duration) do begin
         for ifilter=1,nfilters,1 do begin
             t=get_exptime(duskdawn,expired_time,ifilter,exp0)	; in seconds
; account for two exposures and two file-saves and time to change filter
             expired_time=expired_time+2.*t/60.+2.*0.3/60.+timetochangefilter/60.	; minutes
             print,ifilter,expired_time,' minutes ',t,' s.'
             printf,44,strcompress('SETFILTERCOLORDENSITY,'+FILTERNAME(ifilter-1)+',AIR,,,,,,,',/remove_all)
             printf,44,strcompress('SETFOCUSPOSITION,'+FILTERNAME(ifilter-1)+'_AIR_SKE,,,,,,,,',/remove_all)
	     printf,44,strcompress('WARMSHUTTER,,,,,,,,',/remove_all)
             printf,44,strcompress('SHOOTSINGLES,'+string(t,format='(f6.2)')+',1,512,512,DUSKSKYFLAT_'+FILTERNAME(ifilter-1)+',,,,',/remove_all)
             printf,44,strcompress('SHOOTDARKFRAME,'+string(t,format='(f6.2)')+',1,512,512,DARK,,,,',/remove_all)
	if (expired_time gt duration) then print,'--------DURATION EXPIRED-----------'
             end	; end of ifilter loop
         endwhile
;---------------------
     endif
 close,44
 return
 end
 
 ;.................................................
 ; Writes a script for the 'fake time' mode on the 
 ; eShine telescope
 ; The type of script to be written is selected 
 ; by the user
 ;.................................................
 select_type=2	; FF type  1 is dawn 2 is dusk
 
 setupaFFscript,select_type
 spawn,'cat DOME_part1 > SCRIPT.out'
 spawn,'cat MIDDLE_PART >> SCRIPT.out'
 spawn,'cat separator.txt >> SCRIPT.out'
 spawn,'cat DOME_part2 >> SCRIPT.out'
 spawn,'fromdos SCRIPT.out'
 print,'Output script is in "SCRIPT.out", edit and rename before use.'
 print,'Remember to note in the screen-listing above which is the last useful exposure.'
 end
