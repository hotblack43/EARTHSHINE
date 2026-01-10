PRO goplotdays,jd,am,albedo1,colorchoice
intJD=long(jd)
uniqintJDs=intJD(sort(intJD))
uniqintJDs=uniqintJDs(uniq(uniqintJDs))
n=n_elements(uniqintJDs)
for i=0,n-1,1 do begin
idx=where(long(jd) eq uniqintJDs(i))
m=n_elements(idx)
if (m ge 5) then begin
res=robust_linefit(am(idx),albedo1(idx))
yhat=res(0)+res(1)*am(idx)
if (colorchoice eq '') then oplot,am(idx),yhat
if (colorchoice eq 'red') then oplot,am(idx),yhat,color=fsc_color('red')
print,res(1),colorchoice
endif
endfor
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

PRO getthecommondata,JD1,albedo1,albedo1SD,JD2,albedo2,albedo2SD
 JD=[JD1,JD2]
 JD=JD(sort(JD))
 JD=JD(uniq(JD))
 n=n_elements(JD)
 openw,23,'albedos_from_two_methods.dat'
 for i=0,n-1,1 do begin
     idx=where(JD1 eq JD(i))
     jdx=where(JD2 eq JD(i))
     if (idx(0) ne -1 and jdx(0) ne -1) then begin
         for k=0,n_elements(idx)-1,1 do begin
         	get_everything_fromJD,JD1(idx(k)),phase,azimuth,am
             printf,23,format='(f15.7,7(1x,f11.6))',JD1(idx(k)),albedo1(idx(k)),albedo1SD(idx(k)),albedo2(jdx(k)),albedo2SD(jdx(k)),phase,azimuth,am
             endfor
         endif
     endfor
 close,23
 return
 end
 
 PRO reducemultiplestomeans,JD,albedo,albedoSD
 uniqJDs=JD(SORT(JD))
 uniqJDs=uniqJDs(uniq(uniqJDs))
 n=n_elements(uniqJDs)
 liste=[]
 for i=0,n-1,1 do begin
     idx=where(JD eq uniqJDs(i))
     if (n_elements(idx) ge 2) then begin
         liste=[[liste],[uniqJDs(i),median(albedo(idx),/double),robust_sigma(albedo(idx))]]
         endif else begin
         liste=[[liste],[uniqJDs(i),median(albedo(idx),/double),-0.00]]
         endelse
     endfor
 JD=reform(liste(0,*))
 albedo=reform(liste(1,*))
 albedoSD=reform(liste(2,*))
 return
 end
 
 PRO extract_albedo_list_1,file,JD,albedo,filtertype
 spawn,"cat "+file+" | grep "+filtertype+" |awk '{print $1,$2}'  > getme.dat"
 openr,1,'getme.dat'
 albedo=[]
 jd=[]
 while not eof(1) do begin
     jdin=0.0d0
     alb1=0.0d0
     readf,1,jdin,alb1
     jd=[jd,jdin]
     albedo=[albedo,alb1]
     endwhile
 close,1
 return
 end
 
 
 ;===================================================
 ; Code that produces means of common entries from two lists
 !P.charsize=2
 !P.thick=3
 fmt='(f15.7,2(1x,f10.6))'
 filters=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
 for ifilter=0,4,1 do begin
 !P.MULTI=[0,1,3]
 filtertype=filters(ifilter)
 print,'-------------------------------------'
 print,'Filter: ',filtertype
 otherlistname='CLEM.testing_JAN_21_2015.txt'
 extract_albedo_list_1,otherlistname,JD1,albedo1,filtertype
print,' extracting albedos from list 1...'
 reducemultiplestomeans,JD1,albedo1,albedo1SD
 ;
 otherlistname='CLEM.withflats_JUNE_1_2015.txt'
 extract_albedo_list_1,otherlistname,JD2,albedo2,filtertype
print,' extracting albedos from list 2...'
 reducemultiplestomeans,JD2,albedo2,albedo2SD
;
 getthecommondata,JD1,albedo1,albedo1SD,JD2,albedo2,albedo2SD
 data=get_data('albedos_from_two_methods.dat')
 jd=reform(data(0,*))
 albedo1=reform(data(1,*))
 albedo1SD=reform(data(2,*))
 albedo2=reform(data(3,*))
 albedo2SD=reform(data(4,*))
 phase=reform(data(5,*))
 az=reform(data(6,*))
 am=reform(data(7,*))
plot,title=filtertype,albedo1,albedo2,psym=7,/isotropic,xstyle=3,ystyle=3,xtitle='Albedo wo FF',ytitle='Albedo with FF'
oploterr,albedo1,albedo2,albedo2sd
;
plot,psym=-7,yrange=[min([albedo1,albedo2]),max([albedo1,albedo2])],xstyle=3,ystyle=3,albedo1,title=filtertype,xtitle='Sequence #',ytitle='Albedo from withouta nd with FF (red)'
oplot,psym=-7,albedo2,color=fsc_color('red')
;
plot,psym=7,yrange=[min([albedo1,albedo2]),max([albedo1,albedo2])],xstyle=3,ystyle=3,am,albedo1,title=filtertype,xtitle='Airmass',ytitle='Albedo without and with FF (red)'
oplot,psym=7,am,albedo2,color=fsc_color('red')
goplotdays,jd,am,albedo1,''
goplotdays,jd,am,albedo2,'red'
endfor
 print,'-------------------------------------'
end
