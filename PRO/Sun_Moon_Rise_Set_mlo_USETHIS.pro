PRO get_sunup_sundown,ijd,sunu,sund,lat,lon,sunuhrs,sundhrs
 common obs,obsname
 ; Will return sunset THIS day and sunup NEXT day (i.e. the night start stopis described)
 ; INPUTS
 ; day is the doy
 caldat,ijd,mm,dd,yy,hr,mi,se
 doy=fix(ijd-julday(12,31,2010,0,0,0))
 time=0
 ; find the sundown THIS day
 zensun,doy,time,lat,lon,zenith,azimuth,solfac,sunrise=dummy,sunset=sund
	sund=sund mod 24
 ; find the sunrise NEXT day
 zensun,doy+1,time,lat,lon,zenith,azimuth,solfac,sunrise=sunu,sunset=dummy
	sunu=sunu mod 24
 sunuhrs=sunu
 sundhrs=sund
 ; convert sunu sund to JDs
 sunu=long(ijd)+sunu/24.0d0
 if (obsname eq 'dmi') then sunu=sunu+1
 sund=long(ijd)+sund/24.0d0
 return
 end
 
 ; Will print a table of times for sun and moon rise and set 
 ;
 common obs,obsname
 common lims,sun_lim,am_lim
 mostring=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
 sun_lim=-5
 am_lim=2
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 ; note the minus sign - lon follows observatory.pro and -lon what zensun expects (USA is neg lon)
 lon=-obs_struct.longitude
 print,'lon,lat: ',lon,lat
 jdstart=double(julday(3,15,2012,12,0,0))
 jdend=double(julday(3,16,2013,12,0,0))
 jdstep=1.
 openw,5,strcompress(obsname+'_sunu_sund.txt',/remove_all)
 openw,4,strcompress(obsname+'_list.txt',/remove_all)
 for ijd=jdstart,jdend,jdstep do begin
     caldat,ijd,mm,dd,yy,hr,mi,sec
     ; analyze temp.tmp
     if (dd le 9) then ddstr=strcompress('0'+string(dd),/remove_all)
     if (dd gt 9) then ddstr=strcompress(string(dd),/remove_all)
     ddstr=' '+ddstr
     str=strcompress(mostring(mm-1)+ddstr+string(yy))+':'+string(long(ijd))+':'
     str2=str
     iflag=1
     moonrise=-911
     ic=1
     ifrac=6	; give the inverse fraction of an hour for the time step (i.e. 4= 15 min, 6 = 10 mins)
     for kjd=ijd,ijd+1,1./24./float(ifrac) do begin
         moonpos, kJD, RAmoon, DECmoon
         eq2hor, ramoon, decmoon, kjd, alt_moon, az, ha,  OBSNAME=obsname
         am = airmass(kJD, RAmoon*!dtor, DECmoon*!dtor, obs_struct.latitude*!dtor, obs_struct.longitude*!dtor)
         if (am lt 0) then stop
         mphase,kjd,k
         phase=abs(acos(2.*k-1.)/!dtor)
         sunpos, kJD, RAsun, DECsun
         eq2hor, RAsun, DECsun, kjd, alt_sun, az, ha,  OBSNAME=obsname
         ; Legend:
	 ; s    = Sun is up
         ; .    	= Moon is not up 
         ; +	= Moon is up but too low in sky 
         ; m	= Moon is too new for CoAdd mode
         ; M	= Moon is too near Full for CoAdd mode
         ; C	= Moon is just right for CoAdd mode
         if (alt_sun gt sun_lim) then begin
		str=str+'s'	
	 endif else begin
         if (alt_moon lt 0) then str=str+'.'	
         if (am gt am_lim and alt_moon gt 0) then str=str+'+'	
         if (am le am_lim) then begin
             if (k le 0.11 and alt_moon ge 0) then str=str+'m'	
             if (k gt 0.11 and k lt .58 and alt_moon gt 0) then str=str+'C'	
             if (k ge .58) then str=str+'M'	
             caldat,kjd,dummm,dumdd,dumyy,mhh,mmi,msec
             if (iflag ne 314) then begin
                 moonrise=string(mhh+mmi/60.)
                 iflag=314
                 endif
             endif
         endelse
	if (((ic)/float(ifrac)) eq (fix((ic)/float(ifrac)))) then str=str+' '
	 ic=ic+1
         endfor
     ; add the Rise and set times
     moonrise_str=''
     if (moonrise ne -911) then moonrise_str='/M:'+string(moonrise,format='(f4.1)')
     str=strcompress(str)
     print,strtrim(str)
     printf,4,strtrim(str)
     endfor
         print,strcompress(' Legend: Each line is one Julian Day. Each symbol represents '+string(fix(60./ifrac))+' minutes')
	 print,'The indicated JD # is for the JD starting right after noon (GMT) on the indicated date.'
         print,' s  	= Sun is up' 
         print,' .    	= Moon is not up' 
         print,' +	= Moon is up but too low in sky '
         print,' m	= Moon is too new for CoAdd mode'
         print,' M	= Moon is too near Full for CoAdd mode'
         print,' C	= Moon is just right for CoAdd mode'
         printf,4,strcompress(' Legend: Each line is one Julian Day. Each symbol represents '+string(fix(60./ifrac))+' minutes')
	 printf,4,'The indicated JD # is for the JD starting right after noon (GMT) on the indicated date.'
         printf,4,' s  	= Sun is up' 
         printf,4,' .  	= Moon is not up' 
         printf,4,' +	= Moon is up but too low in sky '
         printf,4,' m	= Moon is too new for CoAdd mode'
         printf,4,' M	= Moon is too near Full for CoAdd mode'
         printf,4,' C	= Moon is just right for CoAdd mode'
 close,4
 close,5
 end
