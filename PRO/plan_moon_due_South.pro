PRO moonphase_pth,jd,phase_angle_M,alt_moon,az_moon,alt_sun,obsname
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


 observatory, obsname, obs
 observatory_longitude = obs.longitude
 observatory_latitude  = obs.latitude
 observatory_altitude  = obs.altitude
 
;print,'Lon,lat,altitude,name of observatory : ',obs.longitude,obs.latitude,obs.altitude,obsname
 
 MOONPOS, jd, ra_moon, DECmoon, dis
 eq2hor, RA_moon, DECmoon, JD, alt_moon, az_moon, ha, LAT=observatory_latitude , LON=observatory_longitude , OBSNAME=obsname , $
 PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
 SUNPOS, jd, ra_sun, DECsun
 eq2hor, RA_sun, DECsun, JD, alt_sun, az, ha, LAT=observatory_latitude , LON=observatory_longitude , OBSNAME=obsname , $
 PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
 
 RAdiff = ra_moon - ra_sun
 sign = +1
 if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
 phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
 phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
 return
 end
; Code to help plan when Moonis due South from MLO
openw,5,'jd_k_az.dat'
openw,4,'Meridian_Moon_Table.dat'
jd1=systime(/julian)
jd1=double(julday(9,1,2011))
jd2=jd1+35.0d0
jdstep=1.0d0/24.0d0/60.0d0/4.
fmtstr='(i2,1x,i2,1x,i4,1x,i2,1x,i2,1x,f4.1,4(a,f9.2))'
OBSNAME='MLO'
for jd=jd1,jd2,jdstep do begin
caldat,jd,mm,dd,yy,hh,mi,se
moonphase_pth,jd,phase_angle_M,alt_moon,az_moon,alt_sun,obsname
MPHASE, jd, k
printf,5,jd-jd1,k,az_moon,alt_sun
if (alt_sun le 0 and alt_moon gt 30 and az_moon gt 178 and az_moon lt 182) then begin
print,format=fmtstr,mm,dd,yy,hh,mi,se,' Frac: ',k,' Am: ',alt_moon,' As: ',alt_sun,' Azm: ',az_moon
printf,4,format=fmtstr,mm,dd,yy,hh,mi,se,' Frac: ',k,' Am: ',alt_moon,' As: ',alt_sun,' Azm: ',az_moon
endif
endfor
close,4
close,5
data=get_data('jd_k_az.dat')
jd=reform(data(0,*))
k=reform(data(1,*))
az=reform(data(2,*))
altsun=reform(data(3,*))
!P.charsize=2
contour,k,jd,az,/irregular,xtitle='Days since 9/1',ytitle='Lunar Azimuth',title='Lunar k, and Solar altitude (thick)',/cell_fill,yrange=[70,290],ystyle=1,nlevels=101,xstyle=1
contour,k,jd,az,/irregular,/overplot,levels=(findgen(12)-1)*0.1,c_labels=indgen(12)*0+1
levs=[-200,0,200]
contour,altsun,jd,az,/irregular,/overplot,/downhill,levels=levs,c_thick=[1,3,1]
end

