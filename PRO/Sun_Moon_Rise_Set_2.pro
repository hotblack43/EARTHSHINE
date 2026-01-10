; Will print a table of times for sun and moon rise and set 
 ;
 common obs,obsname
 common lims,sun_lim,am_lim
 mostring=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
 sun_lim=5
 am_lim=2
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 print,'lon,lat: ',lon,lat
 jdstart=double(julday(1,1,2011,0,0,0))
 jdend=double(julday(1,1,2012,0,0,0))
 jdstep=1.
 openw,4,strcompress(obsname+'_list.txt',/remove_all)
 for ijd=jdstart,jdend,jdstep do begin
     caldat,ijd,mm,dd,yy,hr,mi,sec
     day=ijd-julday(1,1,yy,0,0,0)
     time=12.
; first find sundown this day
     zensun,day,time,lat,lon,zenith,azimuth,solfac,dummy,sund
; then find sunup next day
     zensun,day+1,time,lat,lon,zenith,azimuth,solfac,sunu,dummy
	sunu=sunu+24
     if (sund lt 0) then stop
     sunuhrs=sunu
     sundhrs=sund
     ; convert sunu sund to JDs
     if (sunu ge 0) then begin
         sunuhrs=sunu
         sunu=julday(mm,dd,yy,fix(sunu),60.*(sunu-fix(sunu)))
         endif
     if (sunu lt 0) then begin
         sunuhrs=24+sunu
         sunu=julday(mm,dd-1,yy,fix(24+sunu),60.*((24+sunu)-fix(24+sunu)))
         endif
     sund=julday(mm,dd,yy,fix(sund),60.*(sund-fix(sund)))
     ; analyze temp.tmp
     if (dd le 9) then ddstr=strcompress('0'+string(dd),/remove_all)
     if (dd gt 9) then ddstr=strcompress(string(dd),/remove_all)
     ddstr=' '+ddstr
     str=strcompress(mostring(mm-1)+ddstr+string(yy))+':'
     duration=(24.*(sund-sunu))
     str=str+string(duration,format='(f4.1)')+' h '
     iflag=1
     moonrise=-911
     for kjd=sund,sunu,1./24./4. do begin
         moonpos, kJD, RAmoon, DECmoon
         eq2hor, ramoon, decmoon, kjd, alt_moon, az, ha,  OBSNAME=obsname
         observatory,obsname,obs_struct
         am = airmass(iJD, RAmoon*!dtor, DECmoon*!dtor, obs_struct.latitude*!dtor, obs_struct.longitude*!dtor)
	if (am lt 0) then stop
	mphase,kjd,k
        phase=abs(acos(2.*k-1.)/!dtor)
; Legend:
; _    	= Moon is not up 
; -	= Moon is up but too low in sky 
; m	= Moon is too new for CoAdd mode
; M	= Moon is too near Full for CoAdd mode
; C	= Moon is just right for CoAdd mode
         if (alt_moon lt 0) then str=str+'_'	
	
         if (am gt am_lim and alt_moon gt 0) then str=str+'-'	
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
     risesetstr='S:'+string(sunuhrs,format='(f4.1)')
     str=strcompress(str)+strcompress(risesetstr+moonrise_str,/remove_all)
     print,strtrim(str)
     printf,4,strtrim(str)
     endfor
 close,4
 end
