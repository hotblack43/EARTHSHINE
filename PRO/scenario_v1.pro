observatory_names=['MSO','holi','saao','keck','lapalma']
n_obs=n_elements(observatory_names)
jdstart=double(julday(5,25,2004)+0.11)
jdstop=double(julday(6,3,2004))
jdstep=1./24.d0
for jd=jdstart,jdstop-jdstep,jdstep do begin
	caldat,jd,mm,dd,yy,hour,min,sec
	print,jd,mm,dd,yy,hour,min,sec
	for iobs=0,n_obs-1,1 do begin
		obsname=observatory_names(iobs)
		dat_str=strcompress(string(mm)+'/'+string(dd)+'/'+string(yy)+' at '+string(hour)+':'+string(min)+':'+string(fix(sec)))
		doy=fix(julday(mm,dd,yy)-julday(12,31,yy-1))
		time=hour+min/60.d0+sec/3600.d0
		loadct,39
; First see if Moon is vissible from the chosen observatory atthe given time
; and whether the SUn has set
		MOONPOS, jd, ra_moon, dec_moon, dis
		distance=dis/6371.
		eq2hor, ra_moon, dec_moon, jd, alt_moon_obs, az_moon, ha_moon,  OBSNAME=obsname
		SUNPOS, jd, ra_sun, dec_sun
		eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha, OBSNAME=obsname
		print,alt_moon_obs,alt_sun
		if (alt_moon_obs gt 45 and alt_sun lt -5) then begin
			; see the earth from the Moon
			finding_longlat_moon_at_zenith,mm,dd,yy,hour,min,sec,longitude,latitude
			map_set,latitude,longitude,0,/satellite,sat_p=[distance,0,0],title=strcompress(dat_str+' Obs = '+obsname+' as seen from Moon'),/isotropic,/advance
			;map_set,/mollweide,title=strcompress(dat_str+': '+obsname)
			map_continents,/overplot,title=title,/fill,color=220
			for longitude=0,359,5 do begin
				for latitude=-90,90,5 do begin
					; for point lon,lat checkif Moon and SUn are both vissible
					MOONPOS, jd, ra_moon, dec_moon, dis
					eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon, lat=latitude, lon=longitude
					SUNPOS, jd, ra_sun, dec_sun
				        eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha, lat=latitude, lon=longitude
					if (alt_moon gt 0.0 and alt_sun gt 0.0) then begin
						; OK so Sun and Moon are vissible from or iluminating that point
						plots,longitude,latitude,psym=7
					endif
				endfor
			endfor
			map_continents,/overplot,title=title,color=255,mlinethick=2
		endif	; end of if moon vissible
	endfor	; iobs loop
endfor	; jd loop
end

