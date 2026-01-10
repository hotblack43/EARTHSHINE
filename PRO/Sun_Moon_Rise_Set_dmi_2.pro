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
 obsname='dmi'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 ; note the minus sign - lon follows observatory.pro and -lon what zensun expects (USA is neg lon)
 lon=-obs_struct.longitude
 print,'lon,lat: ',lon,lat
 jdstart=double(julday(1,1,2011,0,0,0))
 jdend=double(julday(1,1,2012,0,0,0))
 jdstep=1.
 openw,5,strcompress(obsname+'_sunu_sund.txt',/remove_all)
 openw,4,strcompress(obsname+'_list.txt',/remove_all)
 for ijd=jdstart,jdend,jdstep do begin
     caldat,ijd,mm,dd,yy,hr,mi,sec
     ; find sunup and sundown atthis place on this day
     get_sunup_sundown,ijd,sunu,sund,lat,lon,sunuhrs,sundhrs
     ; analyze temp.tmp
     if (dd le 9) then ddstr=strcompress('0'+string(dd),/remove_all)
     if (dd gt 9) then ddstr=strcompress(string(dd),/remove_all)
     ddstr=' '+ddstr
     str=strcompress(mostring(mm-1)+ddstr+string(yy))+':'
     str2=str
     iflag=1
     moonrise=-911
     for kjd=sund,sunu,1./24./4. do begin
         moonpos, kJD, RAmoon, DECmoon
         eq2hor, ramoon, decmoon, kjd, alt_moon, az, ha,  OBSNAME=obsname
         am = airmass(kJD, RAmoon*!dtor, DECmoon*!dtor, obs_struct.latitude*!dtor, obs_struct.longitude*!dtor)
         if (am lt 0) then stop
         mphase,kjd,k
         phase=abs(acos(2.*k-1.)/!dtor)
         ; Legend:
         ; .    	= Moon is not up 
         ; +	= Moon is up but too low in sky 
         ; m	= Moon is too new for CoAdd mode
         ; M	= Moon is too near Full for CoAdd mode
         ; C	= Moon is just right for CoAdd mode
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
         endfor
     ; add the Rise and set times
     moonrise_str=''
     if (moonrise ne -911) then moonrise_str='/M:'+string(moonrise,format='(f4.1)')
     risesetstr='S:'+string(sundhrs,format='(f4.1)')
     str=strcompress(str);+strcompress(risesetstr+moonrise_str,/remove_all)
     print,strtrim(str)
     printf,4,strtrim(str)
     printf,5,format='(a,2(1x,i2,1x,i2,1x,f4.1,a))',str2,sixty(sundhrs),' ; ',sixty(sunuhrs)
     endfor
         print,' Legend:'
         print,' .    	= Moon is not up' 
         print,' +	= Moon is up but too low in sky '
         print,' m	= Moon is too new for CoAdd mode'
         print,' M	= Moon is too near Full for CoAdd mode'
         print,' C	= Moon is just right for CoAdd mode'
         printf,4,' Legend:'
         printf,4,' .    	= Moon is not up' 
         printf,4,' +	= Moon is up but too low in sky '
         printf,4,' m	= Moon is too new for CoAdd mode'
         printf,4,' M	= Moon is too near Full for CoAdd mode'
         printf,4,' C	= Moon is just right for CoAdd mode'
 close,4
 close,5
 end
