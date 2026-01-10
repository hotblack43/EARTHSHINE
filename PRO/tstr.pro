PRO get_sunglintpos,jd_i,glon,glat,az_moon,alt_moon,moonlat,moonlong
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
        sunglint,doy(0),time(0),moonlat,moonlong,altitude(0),glat,glon,gnadir,gaz
return
end

jd=systime(/julian)
obsname='mlo'
        MOONPOS, jd, ra_moon, dec_moon, dis, geolon,geolat
        eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
        caldat,jd,mm,dd,yy,hour,min,sec
        doy=fix(julday(mm,dd,yy)-julday(12,31,yy-1))
        time=hour+min/60.d0+sec/3600.d0

print,jd, ra_moon, dec_moon, dis, geolon,geolat,alt_moon, az_moon, ha_moon,mm,dd,yy,hour,min,sec,doy,time
        finding_longlat_moon_at_zenith,mm,dd,yy,hour,min,sec,longitude,latitude
        altitude=(dis-6371.d0);   /1000.0d0     ;km
        moonlat=latitude(0)
        moonlong=longitude(0)
get_sunglintpos,jd,glon,glat,az_moon,alt_moon,moonlat,moonlong
print,jd,glon,glat,az_moon,alt_moon,moonlat,moonlong
end

