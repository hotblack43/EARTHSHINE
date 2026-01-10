pro extract_p_mlo,jd_want,p_out
common flags_meteoro,mlo_flag,jdmetcorr,meteo_pressure
if (mlo_flag ne 314) then begin
; INPUT	- jd JULIAN DAY with fractions
; get all the met data from MLO for 2011+2012:
print,'reading ...'
restore,'/media/thejll/OLDHD/idlsave.dat'
; get rid of flagged observations
temp_at_2m=reform(data(10,*))
temp_at_tower_top=reform(data(12,*))
rel_hum=reform(data(13,*))
meteo_pressure=reform(data(9,*))
idx=where(meteo_pressure gt 100 and rel_hum gt -10 and temp_at_2m gt -90 and temp_at_tower_top gt -90)
data=data(*,idx)
;
year=reform(data(1,*))
month=reform(data(2,*))
day=reform(data(3,*))
hour=reform(data(4,*))
minute=reform(data(5,*))
jdmetcorr=julday(month,day,year,hour,minute)
wind_dir=reform(data(6,*))
wind_speed=reform(data(7,*))
dummy=reform(data(8,*))
meteo_pressure=reform(data(9,*))
temp_at_2m=reform(data(10,*))
temp_at_10m=reform(data(11,*))
temp_at_tower_top=reform(data(12,*))
Tgradient=float(temp_at_tower_top)-float(temp_at_2m)
rel_hum=reform(data(13,*))
precip_intensity=reform(data(14,*))
mlo_flag=314
endif
if (jd_want lt min(jdmetcorr) or jd_want gt max(jdmetcorr)) then stop
p_out=interpol(meteo_pressure,jdmetcorr,jd_want)
return
end
 PRO gomakefilewithJDsforairmasslessthan2,CLEMfile
 openw,33,'JDsforAMlessthan2'
 spawn,"awk '{print $1}' "+CLEMfile+" > allJDs"
 JDs=get_data('allJDs')
 n=n_elements(JDs)
 airmass=fltarr(n)
 for i=0,n-1,1 do begin
 inJD=JDs(i)
 get_everything_fromJD,inJD,phase,azimuth,am,longlint
 if (am le 2.0) then printf,33,format='(f15.7)',inJD
 endfor
 close,33
 return
 end

 PRO preprocess,x_in,y_in
 x=x_in
 y=y_in
 niter=n_elements(y)/2
 snr_max=1e-22
 for iter=0,niter-1,1 do begin
     res=robust_linefit(X, Y, YFIT, SIG, COEF_SIG)
     SNR=abs(coef_sig(1)/res(1))
     if (SNR gt snr_max) then begin
	get_lun,igty8tiyu5u64
	openw,igty8tiyu5u64,'temptrash.eraseme'
	for k=0,n_elements(x)-1,1 do printf,igty8tiyu5u64,x(k),y(k)
	close,igty8tiyu5u64
	free_lun,igty8tiyu5u64
	endif
 d=abs(y-median(y))
 idx=where(d ne max(d))
 x=x(idx)
 y=y(idx)
 endfor
 data=get_data('temptrash.eraseme')
 x_in=reform(data(0,*))
 y_in=reform(data(1,*))
 return
 end

 PRO goBOOTstrap,x_in,y_in,albedo,err_up,err_dn
 n=n_elements(x_in)
 nboot=1000
 openw,74,'temptrash.dat'
 for iboot=0,nboot-1,1 do begin
     idx=fix(randomu(seed,n)*n)
     x=x_in(idx);+randomn(seed,n_elements(idx))*0.001
     y=y_in(idx)
     ;res1=ladfit(X, Y) 
     res1=robust_linefit(X, Y, YFIT, SIG, COEF_SIG)
     printf,74,res1(0)
     endfor
 close,74
 data=get_data('temptrash.dat')
 data=10^(-data/2.5)
 data=data(sort(data))
 albedo=median(data)
 ; +/- 1 SD
 err_up=data(nboot*0.83)-albedo
 err_dn=data(nboot*0.16)-albedo
 ; +/- 1 Quartile
 err_up=data(nboot*0.75)-albedo
 err_dn=data(nboot*0.25)-albedo
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
 
 PRO get_everything_fromJD,JD,phase,azimuth,am,longlint
 common flags_meteoro,mlo_flag,jdmetcorr,meteo_pressure
 common ifwantmeteocorr,if_meteo_correct
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 ; get the phase and azimuth
 MOONPHASE,jd,azimuth,phase,alt_moon,alt_sun,obsname
 ; get the airmass
 moonpos, JD, RAmoon, DECmoon
 wave=0.56	; in microns
 temp=10.	; in deg C
 relhum=30.	; in %
 if (if_meteo_correct eq 1) then begin
      extract_p_mlo,jd,p_out
      pressure=p_out	; make 
      am = airmass(JD, RAmoon*!dtor, $
      DECmoon*!dtor, lat*!dtor, lon*!dtor,wave,pressure,temp,relhum)
 endif
 if (if_meteo_correct ne 1) then am = airmass(JD, RAmoon*!dtor, $
      DECmoon*!dtor, lat*!dtor, lon*!dtor)
 ; get the longlint
 longlint=am*0.0
 ;get_sunglintpos,jd,longlint,glat,az_moon,alt_moon,moonlat,moonlong
 return
 end
 
 PRO getAM,JD,am,lg
 n=n_elements(JD)
 am=fltarr(n)
 lg=fltarr(n)
 for k=0,n-1,1 do begin
     get_everything_fromJD,JD(k),phase,azimuth,airmass,longlint
     am(k)=airmass
     lg(k)=longlint
     endfor
 return
 end
 
 PRO gooplot2,x,y,plcol,str,psymval
 print,'---------------------------------------------------'
 print,str
 print,n_elements(x)
 oplot,x,y-median(y),psym=psymval,color=fsc_color(plcol)
 res1=robust_linefit(X, Y, yhat1, SIG, COEF_SIG)
 oplot,x,yhat1-median(yhat1),color=fsc_color(plcol)
 print,format='(2(a,f7.3))','k: ',res1(1), ' +/- ',coef_sig(1),' per airmass'
 print,format='(2(a,f7.3))',' mag at 0 airmass: ',res1(0), ' +/- ',coef_sig(0)
;printf,22,strcompress('k_'+str,/remove_all)+' = '+string(res1(1),format='(f7.3)')+' +/- ',string(coef_sig(1),format='(f7.3)')
 printf,22,string(res1(1),format='(f8.4)')+' $\pm$ ',string(coef_sig(1),format='(f8.4)')+' & '
 return
 end
 
 
 PRO gooplot,x,y,plcol,str,psymval
; first clean the data for outliers
;preprocess,x,y
 ;print,'x: ',x
 ;print,'y: ',y
 print,n_elements(x)
 oplot,x,y,psym=psymval,color=fsc_color(plcol)
 res1=robust_linefit(X, Y, YFIT, SIG, COEF_SIG)
 ;res1=ladfit(x,y)
 yhat1=res1(0)+res1(1)*x
 print,format='(2(a,f6.3))','Slope: ',res1(1), ' +/- ',coef_sig(1)
 print,format='(2(a,f6.3))',' y at 0 airmass: ',res1(0), ' +/- ',coef_sig(0)
 albedo=10^(-res1(0)/2.5)
 err_up=10^(-(res1(0)+coef_sig(0))/2.5)-10^(-res1(0)/2.5)
 err_dn=10^(-(res1(0)-coef_sig(0))/2.5)-10^(-res1(0)/2.5)
 print,format='(a,f6.3,a,2(1x,f7.4))','robust - Albedo at 0 airmass: ',albedo, ' +/- ',err_up,err_dn
 goBOOTstrap,x,y,albedo,err_up,err_dn
 print,format='(a,f6.3,a,2(1x,f7.4))','boot   - Albedo at 0 airmass: ',albedo, ' +/- ',err_up,err_dn
;oplot,x,10^(yhat1/(-2.5)),color=fsc_color(plcol)
 oplot,x,yhat1,color=fsc_color(plcol)
; now the dotted line
 yhat2=res1(0)+res1(1)*[0.0,x]
;oplot,[0.0,x],10^(yhat2/(-2.5)),color=fsc_color(plcol),linestyle=1
 oplot,[0.0,x],yhat2,color=fsc_color(plcol),linestyle=1
 residuals=y-yhat1
 print,'SD of small residuals: ',stddev(residuals(where(abs(residuals)) lt 0.01)) 
 str=strcompress('$'+string(albedo,format='(f7.4)')+'^{+'+string(err_up,format='(f7.4)')+'}'+'_{'+string(err_dn,format='(f7.4)')+'}$')
 return
 end
 
 PRO describewhatwehave,filtername,jdarray
 print,'-------------------------------------------'
 print,filtername,' : ',n_elements(jdarray)
 z=jdarray(sort(jdarray))
 z=z(uniq(z))
 print,format='(a,500(1x,f15.7))','Uniques : ',z
 print,'Deltas [min]:',(z-z(0))*24.*60.
 
 return
 end
 PRO goplothistos,x1,x2,x3,tstr
 zz=[x1,x2,x3]
 print,tstr+' min,max: ',min(zz),max(zz)
 pcol=!P.color
 !X.style=3
 nbins=19
 histo,x1,min(zz),max(zz),(max(zz)-min(zz))/nbins,/abs,xtitle=tstr
 !P.color=fsc_color('red')
 histo,x2,min(zz),max(zz),(max(zz)-min(zz))/nbins*1.0453,/abs,/overplot
 !P.color=fsc_color('green')
 histo,x3,min(zz),max(zz),(max(zz)-min(zz))/nbins/1.06547,/abs,/overplot
 !P.color=pcol
 return
 end
 
 PRO getstuff,filename,cmd,out
 data=get_data(filename)
 ; JD,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,yshift,corefactor,contrast,RMSE,totfl,zodi,SLcounts
 if (cmd eq 'JD') then designator=0
 if (cmd eq 'Albedo') then designator=1
 if (cmd eq 'Delta Albedo') then designator=2
 if (cmd eq 'Alfa') then designator=3
 if (cmd eq 'ped') then designator=5
 if (cmd eq 'xshift') then designator=6
 if (cmd eq 'cf') then designator=8
 if (cmd eq 'contrast') then designator=9
 if (cmd eq 'RMSE') then designator=10
 if (cmd eq 'flux') then designator=14
;help,designator
 out=reform(data(designator,*))
 out=[]
 dalbedo=reform(data(2,*))
 albedo=reform(data(1,*))
 alfa=reform(data(3,*))
 contrast=reform(data(9,*))
 test1=((albedo lt 1.7) and (albedo gt 0.22))
 test3=((dalbedo lt 2) and (dalbedo gt 0))
 test5=(alfa lt 5.3)
 test6=(contrast gt 0)
 if (1 gt 2) then begin
     print,'albedo:',albedo
     print,test1
     print,'dalbedo:',dalbedo
     print,test3
     print,'alfa:',alfa
     print,test5
     print,'contrast:',contrast
     print,test6
     endif
 idx=where(test1*test3*test5*test6 eq 1)
 if (idx(0) ne -1) then out=reform(data(designator,idx))
 return
 end
