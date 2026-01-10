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
 jdstart=double(julday(3,6,2011,0,0,0))
 jdend=double(julday(3,8,2011,0,0,0))
 jdstep=1./24.0/12.
 ic=0
 for ijd=jdstart,jdend,jdstep do begin
     caldat,ijd,mm,dd,yy,hr,mi,sec
     if (dd le 9) then ddstr=strcompress('0'+string(dd),/remove_all)
     if (dd gt 9) then ddstr=strcompress(string(dd),/remove_all)
     ddstr=' '+ddstr
     str=strcompress(mostring(mm-1)+ddstr+string(yy))+':'
;
         moonpos, iJD, RAmoon, DECmoon
         eq2hor, ramoon, decmoon, ijd, alt_moon, az, ha,  OBSNAME=obsname
	 sunpos, iJD, RAsun, DECsun
         eq2hor, RAsun, DECsun, ijd, alt_sun, az, ha,  OBSNAME=obsname
	if (ic eq 0) then begin
	time=ijd-julday(12,31,yy-1)
	sun=alt_sun
	moon=alt_moon
	endif
	if (ic gt 0) then begin
	time=[time,ijd-julday(12,31,yy-1)]
	sun=[sun,alt_sun]
	moon=[moon,alt_moon]
	endif
 ic=ic+1
  endfor
 plot,time,sun,color=fsc_color('yellow'),xtitle='Time [doy]',ytitle='Altitude',yrange=[-5,60],ystyle=1
 oplot,time,moon,color=fsc_color('blue')
 plots,[!x.crange],[0,0],linestyle=2
 plots,[!x.crange],[30,30],linestyle=2,color=fsc_color('blue')
 end
