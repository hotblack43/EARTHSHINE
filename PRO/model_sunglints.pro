PRO get_sunglintpos,jd_i,glon,glat
        caldat,jd_i,mm,dd,yy,hr,mi,sec
        jd=jd_i
        MOONPOS, jd, ra_moon, dec_moon, dis, geolon,geolat
        eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
        caldat,jd,mm,dd,yy,hour,min,sec
        doy=fix(julday(mm,dd,yy)-julday(12,31,yy-1))
        time=hour+min/60.d0+sec/3600.d0
; Where on Earth is Moon at zenith?
        finding_longlat_moon_at_zenith,mm,dd,yy,hour,min,sec,longitude,latitude
        altitude=(dis-6371.d0);   /1000.0d0     ;km
        moonlat=latitude(0)
        moonlong=longitude(0)
        sunglint,doy,time,moonlat,moonlong,altitude,glat,glon,gnadir,gaz
return
end

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Code to plot any observing times' sunglint position on a map
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
obsname='lapalma'
obsname='PALOMAR'
trs=strcompress('Sunglint positions from '+obsname+': Sun down Moon up')
openw,44,'any_sunglint_coords.dat'
jdstart=julday(1,1,2011,13,13,13)
jdstop=julday(12,31,2011,13,13,13)
jdstep=(jdstop-jdstart)/365./24.d0/2.
ic=0
for jd=jdstart,jdstop-jdstep,jdstep do begin
; get the Suns position
sunpos, JD, RAsun, DECsun
eq2hor, RAsun, DECsun, JD, sun_altitude, sun_az, ha, OBSNAME=obsname , $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1
moonpos, JD, RAmoon, DECmoon
eq2hor, RAmoon, DECmoon, JD, moon_altitude, moon_az, ha, OBSNAME=obsname , $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1
mphase,jd,k
print,jd,sun_altitude,moon_altitude
if (sun_altitude lt 0 and moon_altitude gt 0) then begin
 get_sunglintpos,jd,glon,glat
if (ic eq 0) then begin
map_set,title=str
map_continents,/overplot
map_grid,/overplot
oplot,[glon,glon],[glat,glat],psym=7,color=fsc_color('red')
endif else begin
oplot,[glon,glon],[glat,glat],psym=7,color=fsc_color('red')
endelse
printf,44,format='(f19.7,3(1x,f9.2))',jd,glon,glat,k
print,format='(f19.7,3(1x,f9.2))',jd,glon,glat,k
ic=ic+1
endif
endfor
close,44
data=get_data('any_sunglint_coords.dat')
jd=reform(data(0,*))
glon=reform(data(1,*))
glat=reform(data(2,*))
illumfr=reform(data(3,*))
;contour,illumfr,glon,glat,/irregular,levels=findgen(11)/10.,c_labels=findgen(11)*0+1
idx=where(illumfr lt 0.25)
oplot,glon(idx),glat(idx),psym=7,color=fsc_color('blue')
end


