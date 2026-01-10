 PRO getunique_integer_JDs,JD,uniqJDs,m
 arr=long(JD(sort(JD)))
 uniqJDs=arr(uniq(arr))
 m=n_elements(uniqJDs)
 return
 end
 
PRO extinction,JD,albedo,airma,filter,phase
 dk=[0.0505194,0.0739563,0.106594,0.0401459,0.0643813]
 filternames=['B','V','VE1','VE2','IRCUT']
; the above are bye-eye estimates foudn setting a='', below and 
; looping over ifilter
 getunique_integer_JDs,JD,uniqJDs,m
 n=n_elements(albedo)
 albedo_new=albedo*0.0
 for iJD=0,m-1,1 do begin
 for ifilter=1,5,1 do begin
     idx=where(filter eq ifilter and long(JD) eq uniqJDs(iJD))
     a='q';'q'
     while(idx(0) ne -1 and a ne 'q') do begin
	 factor_series=10^(0.4*dk(ifilter-1)*airma(idx))
         albedo_new(idx)=albedo(idx)*factor_series
         xx=airma(idx)
         yy=albedo_new(idx)
         plot,xtitle='Z',ytitle='Corrected Albedo',title='Filter '+filternames(ifilter-1)+' JD: '+string(uniqJDs(iJD)),xrange=[1,3],psym=-7,ystyle=3,xstyle=3,xx,yy
       ; a=get_kbrd()
         if (a eq 'u') then dk(ifilter-1)=dk(ifilter-1)*1.03
         if (a eq 'd') then dk(ifilter-1)=dk(ifilter-1)/1.0308765
         print,'k : ',dk(ifilter-1),' median factor: ',median(factor_series)
         endwhile
;stop
     endfor
     endfor
 return
 end
 
 PRO goplotrobustline,x_in,y_in
 idx=where(finite(x_in) eq 1 and finite(y_in) eq 1)
 x=x_in(idx)
 y=y_in(idx)
 res=robust_linefit(x,y,yhat,sig,ss)
 print,res
 print,ss
 oplot,x,10^yhat,color=fsc_color('green')
 return
 end
 
 PRO gofindquartiles,arr_in,q1,q2,q3
 arr=arr_in(sort(arr_in))
 n=n_elements(arr)
 q1=arr(n*0.25)
 q2=arr(n*0.50)
 q3=arr(n*0.75)
 return
 end
 
 PRO gomakemedianline,JD,phase,y
 arr=long(JD(sort(JD)))
 uniqJDs=arr(uniq(arr))
 for k=0,n_elements(uniqJDs)-1,1 do begin
     idx=where(long(JD) eq uniqJDs(k))
     gofindquartiles,y(idx),q1,q2,q3
     printf,88,median(phase(idx)),q1,q2,q3
     print,'Phase and q1,q2,q3: ',median(phase(idx)),q1,q2,q3
     endfor
 return
 end
 
 PRO getuniqueJDs,JD,uniqJDs
 arr=JD(sort(JD))
 uniqJDs=arr(uniq(arr))
 return
 end
 
 PRO getfiltertypefromJD,JD_in,filtertype
 common switches,iflag,data,jd,ty
 if (iflag ne 314) then begin
     data=get_data('JD_FILTERTYPE.txt')
     jd=reform(data(0,*))
     ty=reform(data(1,*))
     iflag=314
     endif
 idx=where(jd eq jd_in)
 if (idx(0) eq -1) then stop
 filtertype=ty(idx(0))
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
 
 PRO get_everything_fromJD,JD,phase,azimuth,am
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 ; get the phase and azimuth
 MOONPHASE,jd,azimuth,phase,alt_moon,alt_sun,obsname
 ; get the airm
 moonpos, JD, RAmoon, DECmoon
 am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
 return
 end
 
 PRO get_JD_from_filename,str,JDstr
 idx=strpos(str,'245')
 JDstr=strmid(str,idx,7)
 return
 end
 
 ;=======================================================================
 ;= MAIN CODE describe_CLEM_file.pro
 ;= Prints and plots various summaries of data in files from fit_ideal...
 ;=======================================================================
 common switches,iflag,datafortypes,jdfortypes,types
 iflag=1
 filternames=['B','V','VE1','VE2','IRCUT']
 ;-----------------------------------------
 openw,88,'medianphaseandquartiles.dat'
 ;files=file_search('CLEM.testing_FEB_20_2015_steponly_weighted.txt',count=n););CLEM.testing_*_2014_JD*.txt',count=n)
 files=file_search('CLEM.testing_JAN_21_2015.txt',count=n););CLEM.testing_*_2014_JD*.txt',count=n)
 ;files=file_search('CLEM.testing_*_2014_JD*.txt',count=n)
 openw,44,'alldata.dat'
 for ifile=0,n-1,1 do begin
     print,'Looking at file '+files(ifile)
     get_JD_from_filename,files(ifile),JDstr
     spawn,"wc "+files(ifile)+" | awk '{print $2/$1}' > tst"
     ncols=get_data('tst')
     ncols=ncols(0)-1
     str="awk '{print "
     for k=1,ncols-2,1 do str=str+strcompress('$'+string(k)+',',/remove_all)
     str=str+strcompress('$'+string(k),/remove_all)+"}' "+files(ifile)+" > aha13"+"_"+JDstr
     spawn,str
     data=get_data('aha13'+"_"+JDstr)
     JD=reform(data(0,*))
     albedo=reform(data(1,*))
     erralbedo=reform(data(2,*))
     alfa1=reform(data(3,*))
     rlimit=reform(data(4,*))
     pedestal=reform(data(5,*))
     xshift=reform(data(6,*))
     yshift=reform(data(7,*))
     corefactor=reform(data(8,*))
     lamda0=reform(data(9,*))
     RMSE=reform(data(10,*))
     totfl=reform(data(11,*))
     zodi=reform(data(12,*))
     SLcounts=reform(data(13,*))
     flux=reform(data(14,*))
     nlines=n_elements(JD)
     phase=[]
     openw,33,strcompress('table'+'_'+JDstr+'.dat',/remove_all)
     fmt_str='(f15.7,1x,f7.2,1x,f9.5,1x,i2,1x,f6.3)'
     for iJD=0,nlines-1,1 do begin
         get_everything_fromJD,reform(JD(iJD)),ph,azimuth,airm
         getfiltertypefromJD,JD(iJD),filtertype
         printf,33,format=fmt_str,JD(iJD),ph,albedo(iJD),filtertype,airm
         endfor
     close,33
     print,'Wrote '+strcompress('table'+'_'+JDstr+'.dat',/remove_all)
     data=get_data(strcompress('table'+'_'+JDstr+'.dat',/remove_all))
     JD=reform(data(0,*))
     phase=abs(reform(data(1,*)))
     albedo=reform(data(2,*))
     filter=reform(data(3,*))
     airma=reform(data(4,*))
     extinction,JD,albedo,airma,filter,phase
     getuniqueJDs,JD,uniqJDs
     for l=0,n_elements(uniqJDs)-1,1 do begin
         idx=where(JD eq uniqJDs(l))
         printf,44,format='(i3,1x,f15.7,5(1x,f9.4))',l,uniqJDs(l),median(phase(idx)),median(albedo(idx)),robust_sigma(albedo(idx)),median(filter(idx)),median(airma(idx))
         endfor
     endfor
 close,44
 ; plot alldata.dat for each filter
 data=get_data('alldata.dat')
 !P.MULTI=[0,3,2]
 !P.CHARTHICK=3
 if_wantrelplot=1
 if (if_wantrelplot eq 1) then begin
     for ifilter=1,5,1 do begin
         idx=where(data(5,*) eq ifilter)
         plot_io,yrange=[0.05,10],charsize=1.9,data(2,idx),data(4,idx)/data(3,idx)*100.0,psym=7,title='Filter '+filternames(ifilter-1),xtitle='Lunar phase [FM = 0]',ytitle='Relative error on albedo [%]'
         print,'Median error for filter ',filternames(ifilter-1),' = ',median(data(4,idx)/data(3,idx)*100.0),' %.'
         oplot,[!X.crange],[median(data(4,idx)/data(3,idx)*100.0),median(data(4,idx)/data(3,idx)*100.0)],linestyle=2
         endfor
     plot_io,yrange=[0.05,10],charsize=1.7,data(2,*),data(4,*)/data(3,*)*100.0,psym=7,title=' All Filters',xtitle='Lunar phase [FM = 0]',ytitle='Relative error on albedo [%]'
     gomakemedianline,data(1,*),data(2,*),data(4,*)/data(3,*)*100.0
     close,88
     data=get_data('medianphaseandquartiles.dat')
     idx=sort(data(0,*))
     data=data(*,idx)
     ph=reform(data(0,*))
     q1=reform(data(1,*))
     q2=reform(data(2,*))
     q3=reform(data(3,*))
     !P.THICK=3
     ;    oplot,ph,q2,color=fsc_color('red')
     ;    oplot,ph,q1,linestyle=2,color=fsc_color('red')
     ;    oplot,ph,q3,linestyle=2,color=fsc_color('red')
     endif else begin
     for ifilter=1,5,1 do begin
         idx=where(data(5,*) eq ifilter)
         plot_io,yrange=[1e-4,0.1],charsize=1.9,data(2,idx),data(4,idx),psym=7,title='Filter '+filternames(ifilter-1),xtitle='Lunar phase [FM = 0]',ytitle='Absolute error on albedo'
         goplotrobustline,data(2,idx),alog10(data(4,idx))
         print,'Median error for filter ',filternames(ifilter-1),' = ',median(data(4,idx)),' '
         oplot,[!X.crange],[median(data(4,idx)),median(data(4,idx))],linestyle=2
         endfor
     plot_io,yrange=[1e-4,0.1],charsize=1.8,data(2,*),data(4,*),psym=7,title=' All Filters',xtitle='Lunar phase [FM = 0]',ytitle='Absolute error on albedo'
     goplotrobustline,data(2,*),alog10(data(4,*))
     gomakemedianline,data(1,*),data(2,*),data(4,*)
     close,88
     data=get_data('medianphaseandquartiles.dat')
     idx=sort(data(0,*))
     data=data(*,idx)
     ph=reform(data(0,*))
     q1=reform(data(1,*))
     q2=reform(data(2,*))
     q3=reform(data(3,*))
     !P.THICK=3
     ;    oplot,ph,q2,color=fsc_color('red')
     ;    oplot,ph,q1,linestyle=2,color=fsc_color('red')
     ;    oplot,ph,q3,linestyle=2,color=fsc_color('red')
     endelse
 end
 
