@stuffy
 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 PRO get_radius,header,radius
 idx=where(strpos(header, 'RADIUS') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 RADIUS=float(strmid(str,16,15))
 return
 end
 
 PRO get_discy0,header,discy0
 idx=where(strpos(header, 'DISCY0') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 discy0=float(strmid(str,16,15))
 return
 end
 
 PRO get_discx0,header,discx0
 idx=where(strpos(header, 'DISCX0') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 discx0=float(strmid(str,16,15))
 return
 end
 
 PRO get_measuredexptime,header,measuredtexp
 idx=where(strpos(header, 'DMI_ACT_EXP') ne -1)
 str='999'
 measuredtexp=911
 if (idx(0) ne -1) then begin
     str=header(idx(0))
     measuredtexp=float(strmid(str,24,8))
     endif
 return
 end
 
 PRO get_times,h,exptime
 get_EXPOSURE,h,exptime
 end
 
 PRO getbasicfilename,namein,basicfilename
 print,namein
 basicfilename=strmid(namein,strpos(namein,'.')-7)
 ;basicfilename=strmid(namein,strpos(namein,'2455'))
 return
 end
 
 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end
 PRO MOONPHASE,jd,az_moon,phase_angle_M,alt_moon,alt_sun,obsname
 ;-----------------------------------------------------------------------
 ; Set various constants.
 ;-----------------------------------------------------------------------
 RADEG  = 180.0/!PI
 DRADEG = 180.0D/!DPI
 AU = 149.6d+6       ; median Sun-Earth distance     [km]
 Rearth = 6365.0D    ; Earth radius                [km]
 Rmoon = 1737.4D     ; Moon radius                 [km]
 Dse = AU            ; default Sun-Earth distance  [km]
 Dem = 384400.0D     ; default Earth-Moon distance [km]
 MOONPOS, jd, ra_moon, DECmoon, dis
 distance=dis/6371.
 eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
 SUNPOS, jd, ra_sun, DECsun
 eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname
 RAdiff = ra_moon - ra_sun
 sign = +1
 if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
 phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
 phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
 return
 end
 
 FUNCTION get_JD_from_filename,name
 liste=strsplit(name,'/',/extract)
 idx=strpos(liste,'24')
 ipoint=where(idx eq 0)
 JD=double(liste(ipoint))
 return,JD
 end
 
 PRO get_everything_fromJD,JD,phase,azimuth,am,longlint,glat
 common filehandles,abekat
 ;print,'in get_everything_fromJD, jd is: ',jd
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 alt_moon=[]
 alt_sun=[]
 azimuth=[]
 az_moon=[]
 glat=[]
 longlint=[]
 moonlat=[]
 moonlong=[]
 phase=[]
 azimuth=[]
 am=[]
 
 ; get the phase and azimuth
 for i=0,n_elements(jd)-1,1 do begin
     MOONPHASE,jd(i),azimuth_o,phase_o,alt_moon_o,alt_sun_o,obsname
     ; get the airmass
     moonpos, JD(i), RAmoon, DECmoon
     am_o = airmass(JD(i), RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
     ; get the longlint
     get_sunglintpos,jd(i),longlint_o,glat_o,az_moon_o,alt_moon_o,moonlat_o,moonlong_o
     ;
     alt_moon=[alt_moon,alt_moon_o]
     alt_sun=[alt_sun,alt_sun_o]
     azimuth=[azimuth,azimuth_o]
     glat=[glat,glat_o]
     longlint=[longlint,longlint_o]
     moonlat=[moonlat,moonlat_o]
     moonlong=[moonlong,moonlong_o]
     phase=[phase,phase_o]
     am=[am,am_o]
     endfor
 return
 end
 PRO leastcorner,im,leastval
 w=10
 block1=im(0:w,0:w)
 block2=im(0:w,511-w:511)
 block3=im(511-w:511,0:w)
 block4=im(511-w:511,511-w:511)
 m1=median(block1)
 m2=median(block2)
 m3=median(block3)
 m4=median(block4)
 leastval=min([m1,m2,m3,m4])
 im=im-leastval
 return
 end
 
 
 path='/media/thejll/SAMSUNG/ASTRO/EARTHSHINE/DARKCURRENTREDUCED/'
;path=''
;openr,1,'B_DCR.files'
 openr,1,'V_DCR.files'
 openw,44,'listen.txt'
 !P.MULTI=[0,1,2]
 !P.thick=2
 !P.charthick=3
 !P.charsize=1.6
 oldphase=1e22
 limphase=1
 ic=0
 jc=0
 while not eof(1) do begin
     str=''
     readf,1,str
;str=path+str
     files=file_search(str)
     JD=get_JD_from_filename(files)
     get_everything_fromJD,JD,phase,azimuth,am,longlint,glat
     im=readfits(files,header,/sil)
     im=im/total(im,/double)*2e8
     leastcorner,im,leastval
     get_radius,header,radius
     get_discx0,header,x0
     get_discy0,header,y0
     get_EXPOSURE,header,exptime
     print,format='(f15.7,5(1x,f9.4))',JD,phase,x0,y0,radius,exptime
     printf,44,format='(f9.4,1x,a)',phase,str
     ww=5
     strip=im(*,y0-ww:y0+ww)
     Line=avg(strip,1)
     xx=findgen(512)
     xx=xx-x0
     kdx=where(xx gt -radius-30 and xx lt -radius-10)
     w=50
     tstr=strcompress('Phase selection: '+string(oldphase,format='(f7.1)')+' +/-'+string(limphase,format='(f3.1)'))
     if (phase lt 0) then begin
     if (ic eq 0) then begin
	mval=mean(line(kdx))
        plot,yrange=[0.1,25],title='Phase negative',xx,line,xrange=[-radius-w,-radius+w],xstyle=3,ystyle=3
        oplot,[!x.crange],[0,0],linestyle=2
	endif
     if (ic gt 0 ) then oplot,xx,line-mean(line(kdx))+mval
     ic=ic+1
     endif
     if (phase gt 0) then begin
     if (jc eq 0) then begin
        mval2=mean(line(kdx))
        plot,yrange=[0.1,25],title='Phase negative',xx,line,xrange=[-radius-w,-radius+w],xstyle=3,ystyle=3
        oplot,[!x.crange],[0,0],linestyle=2
        endif
     if (jc gt 0 ) then oplot,xx,line-mean(line(kdx))+mval2
     jc=jc+1
     endif
     endwhile
 close,1
 close,44
 end
