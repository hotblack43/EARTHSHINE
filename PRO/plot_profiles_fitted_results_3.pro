 PRO getcoordsfromheader,header,x0,y0,radius
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
 print,'DISCX0 not in header. Assigning dummy value'
 x0=256.
 endif else begin
 x0=float(strmid(header(jdx),15,9))
 endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
 print,'DISCY0 not in header. Assigning dummy value'
 y0=256.
 endif else begin
 y0=float(strmid(header(jdx),15,9))
 endelse
 idx=strpos(header,'DISCRA')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
 print,'DISCRA not in header. Assigning dummy value'
 radius=134.327880000
 endif else begin
 radius=float(strmid(header(jdx),15,9))
 endelse
 return
 end

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 exptime=exptime(0)
 return
 end



 PRO makecleanlist,file
 print,'Sectioning the CLEM list'
 str="cat "+file+" | awk '{print $1}' | sort > liste.JD"
 spawn,str
 data=get_data('liste.JD')
 n=n_elements(data)
 t1=long(data(0))-0.5
 t2=long(data(n-1))+1.5
 print,format='(a,2(1x,f15.7))','t1,t2 = ',t1,t2
 ;
 get_lun,fdrftse
 openw,fdrftse,'list_of_CLEMforonenight.txt'
 get_lun,jhgkhguy
 openw,jhgkhguy,'willberemoved.txt'
 for t=t1,t2-1.0d0,1.0d0 do begin
     listname=strcompress('liste.'+string(t,format='(f15.7)')+'-'+string(t+1,format='(f15.7)'))
     str="awk '$1 > "+string(t,format='(f15.7)')+" && $1 < "+string(t+1,format='(f15.7)')+"  ''' "+file+" > "+listname
     spawn,str
     printf,fdrftse,listname
     endfor
 close,fdrftse
 free_lun,fdrftse
 openr,fdrftse,'list_of_CLEMforonenight.txt'
 ; get ridof empty files
 while not eof(fdrftse) do begin
     str=''
     readf,fdrftse,str
     if (file_test(str,/ZERO_LENGTH) eq 0) then begin
         print,str,' is nonzero'
         printf,jhgkhguy,str
         endif
     endwhile
 close,fdrftse
 close,jhgkhguy
 free_lun,fdrftse
 free_lun,jhgkhguy
 spawn,'mv willberemoved.txt list_of_CLEMforonenight.txt'
 print,'Sectioned, clean list of filenames is in file list_of_CLEMforonenight.txt'
 return
 end

PRO goplothemap
 common moonisoverhead,longitude,latitude
 !P.CHARSIZE=1.1
 data=get_data('mapme.dat')
 lon=reform(data(0,*))
 lat=reform(data(1,*))
 latrange=max(lat)-min(lat)
 lonrange=max(lon)-min(lon)
 ran=max([latrange,lonrange]);/2.
 map_set,/advance,/satellite,sat_p=[6.6,0,0],/hires,latitude,longitude,0,limit=[-90,-180,90,180],/isotropic
 plots,lon,lat,psym=7,color=fsc_color('red')
 map_continents
 map_grid,londel=15,latdel=15,label=3
 return
 end
 
 FUNCTION zenithangmoon,x
 ; returns Moons zenith angle at Julian day jd (which must be passed via the common block)
 ; used by get_lon_lat_for_moon_at_zenith, below.
 common time,jd
 longitude=x(0)
 latitude=x(1)
 MOONPOS, jd, ra_moon, dec_moon, dis, geolon,geolat
 eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  lon=longitude,lat=latitude
 zenithangMoon=90.-alt_moon
 return,zenithangMoon
 end
 
 PRO get_lon_lat_for_moon_at_zenith,lon,lat
 ; routine for using POWELL to find where the Moon is right overhead on Earth
 ; Define the fractional tolerance:
 ftol = 1.0d-8
 ; Define the starting point:
 P = [0.0d0,0.0d0]
 ; Define the starting directional vectors in column format:
 xi = TRANSPOSE([[1.0, 0.0],[0.0, 1.0]])
 ; Minimize the function:
 POWELL, P, xi, ftol, fmin, 'zenithangmoon',/DOUBLE
 lon=p(0)
 lat=p(1)
 while (lon lt 0) do begin
     lon=360.+lon
     endwhile
 while (lon gt 360.0) do begin
     lon=lon-360.0
     endwhile
 return
 end
 
 PRO get_sunglintpos,jd_i,glon,glat,az_moon,alt_moon,moonlat,moonlong
 ; will return among other things the longitude and latitude on Earth of the sunglint as seen from the Moon
 ; the longitude of the glint is in the 0-360 degree format.
 common time,jd
 common moonisoverhead,longitude,latitude
 caldat,jd_i,mm,dd,yy,hr,mi,sec
 jd=jd_i
 MOONPOS, jd, ra_moon, dec_moon, dis, geolon,geolat
 obsname='mlo'
 eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
 caldat,jd,mm,dd,yy,hour,min,sec
 doy=fix(julday(mm,dd,yy)-julday(12,31,yy-1))
 time=hour+min/60.d0+sec/3600.d0
 ; Where on Earth is Moon at zenith?
 get_lon_lat_for_moon_at_zenith,longitude,latitude
 altitude=(dis-6371.d0);   /1000.0d0     ;km
 moonlat=latitude(0)
 moonlong=longitude(0)
 sunglint,doy,time,moonlat,moonlong,altitude,glat,glon,gnadir,gaz
 return
 end
 
 
 PRO MOONPHASE,jd,az_moon,phase_angle_M,alt_moon,alt_sun,obsname
 ;-----------------------------------------------------------------------
 ; Set various constants.
 ;-----------------------------------------------------------------------
 RADEG  = 180.0/!PI
 DRADEG = 180.0D/!DPI
 AU = 149.6d+6       ; mean Sun-Earth distance     [km]
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
 
 PRO get_everything_fromJD,JD,phase,azimuth,am,longlint
 common filehandles,abekat
 ;print,'in get_everything_fromJD, jd is: ',jd
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 ; get the phase and azimuth
 MOONPHASE,jd,azimuth,phase,alt_moon,alt_sun,obsname
 ; get the airmass
 moonpos, JD, RAmoon, DECmoon
 am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
 ; get the longlint
 get_sunglintpos,jd,longlint,glat,az_moon,alt_moon,moonlat,moonlong
 get_lun,abekat
 openw,abekat,'mapme.dat',/append
 printf,abekat,longlint,glat
 close,abekat
 free_lun,abekat
 return
 end
 
 ; typical use
 ; file='listofJDs.txt'
 ; openr,1,file
 ; ic=0
 ; get_lun,uyujk
 ; openw,uyujk,'ERASMEjkhgjygvf.dat'
 ; while not eof(1) do begin
 ; JD=0.0d0
 ; readf,1,JD
 ; get_everything_fromJD,JD,phase,azimuth,airmass,longlint
 ; print,format='(f15.7,4(1x,f9.3))',JD,phase,azimuth,airmass,longlint
 ; printf,uyujk,format='(f15.7,4(1x,f9.3))',JD,phase,azimuth,airmass,longlint
 ; ic=ic+1
 ; endwhile
 ; print,'N: ',ic
 ; close,1
 ; close,uyujk
 ; data=get_data('ERASMEjkhgjygvf.dat')
 ; phase=reform(data(1,*))
 ; glon=reform(data(4,*))
 ; !P.CHARSIZE=2
 ; plot,phase,glon,psym=7,xtitle='Lunar phase',ytitle='Sunglint longitude [deg East]'
 ; end
 FUNCTION get_JD_from_filename,name
 liste=strsplit(name,'_',/extract)
 idx=strpos(liste,'24')
 ipoint=where(idx ne -1)
 JD=double(liste(ipoint))
 return,JD
 end
 
 ;-------------------------------------------------------------------
 common filehandles,abekat
;file='CLEM.profiles_fitted_results_July_24_2013.txt'
 file='CLEM.profiles_fitted_results_SELECTED_5_multipatch_100_smoo_SINGLES.txt'
 makecleanlist,file
 openr,99,'list_of_CLEMforonenight.txt'
 while (not eof(99)) do begin
     if (file_test('mapme.dat') eq 1) then spawn,'rm mapme.dat'
	filename=''
	readf,99,filename
        daystring=strmid(filename,6,7)
     set_plot,'ps'
     device,/color
     device,xsize=18,ysize=24.5,yoffset=2
     device,filename=strcompress('results_'+string(long(daystring))+'.ps',/remove_all)
     filternames=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
     !P.CHARSIZE=2
     for iplot=1,3,1 do begin	; loop over plot types
         !P.MULTI=[0,2,3]
         for ifilter=0,4,1 do begin
             filterstr=filternames(ifilter)
             print,filterstr
             p='p_'+filterstr
;str="cat "+filename+" | grep "+filternames(ifilter)+" | awk '{print $1,$2,$3}' > "+p
str="cat "+filename+" | grep "+filternames(ifilter)+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' > "+p
             spawn,str
             ;
             if ((file_info(p)).size ne 0) then begin
; JD,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,yshift,corefactor,contrast,RMSE,totfl,name,labelstr
;  0    1      2       3      4      5       6      7       8          9      10    11
                 data=get_data(p)
                 ;rmse=reform(data(10,*))
                 ;idx=where(rmse lt 0.1)
                 ;data=data(*,idx)
;
                 jd=reform(data(0,*))
                 alb=reform(data(1,*))
                 erralb=reform(data(2,*))
                 ;p1=reform(data(3,*))
                 ;p2=reform(data(4,*))
                 ;p3=reform(data(5,*))
                 ;rmse=reform(data(10,*))
                 n=n_elements(jd)
                 get_lun,foo
                 openw,foo,'hej.dat14'
                 for i=0,n-1,1 do begin
                     JDnum=jd(i)
                     get_everything_fromJD,JDnum,ph,azi,airm,longlint
                     printf,foo,format='(f15.7,6(1x,f9.3))',JDnum,ph,azi,airm,longlint,alb(i),erralb(i)
                     endfor
                 close,foo
                 free_lun,foo
                 !P.title=filterstr
                 !y.title='A*'
                 data=get_data('hej.dat14')
                 names=['JD','Phase','Azimuth','Airmass','Glon','Albedo','Abs albedo error']
 ;               if (iplot eq 1) then plot,yrange=[0.1,0.6],xstyle=3,data(0,*) mod 1,data(5,*),psym=1,xtitle=names(0),ytitle=names(5),title=filterstr+daystring
;                 if (iplot eq 2) then plot,yrange=[0.1,0.6],xstyle=3,data(1,*),data(5,*),psym=1,xtitle=names(1),ytitle=names(5),title=filterstr+daystring;,xrange=[-150,150]
                  if (iplot eq 3) then begin
                     plot,yrange=[0.1,0.6],xstyle=3,ystyle=3,data(4,*),data(5,*),psym=1,xtitle=names(4),ytitle=names(5),title=filterstr+daystring
                     res=ladfit(data(4,*),data(5,*))
                     yhat=res(0)+res(1)*data(4,*) & oplot,data(4,*),yhat,color=fsc_color('red') & print,'Slope: ',res(1)
                     endif
                 endif
             endfor
         endfor
     goplothemap
     device,/close
     endwhile
     print,"--------------------------------------------------------------------"
 close,99
 end
