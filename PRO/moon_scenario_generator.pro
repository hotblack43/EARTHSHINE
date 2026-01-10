PRO get_image_to_wrap,jd,image
file='Jul292222.jpg'
read_jpeg,file,im
im=shift(im,-1024,0)	; shift the image to the Greenwich meridian
image=congrid(im,360,181)	; resample to something suitable
return
end

;observatory_names=['Palomar','MSO','holi','saao','keck','lapalma']
observatory_names=['MSO'];,'MSO','holi','saao','keck','lapalma']
loadct,0
device='ps'
if (device eq 'X') then device,decomposed=0
n_obs=n_elements(observatory_names)
jdstart=double(julday(9,4,1999)+0.11)
jdstop=double(julday(10,15,1999))
jdstep=3./24.d0
for jd=jdstart,jdstop-jdstep,jdstep do begin
	caldat,jd,mm,dd,yy,hour,min,sec
	print,jd,mm,dd,yy,hour,min,sec
	for iobs=0,n_obs-1,1 do begin
		obsname=observatory_names(iobs)
		openw,33,strcompress('scenario_dat.'+obsname,/remove_all)

		dat_str=strcompress(string(mm)+'/'+string(dd)+'/'+string(yy)+' at '+string(hour)+':'+string(min)+':'+string(fix(sec)))
		tit_str=strcompress(dat_str+' Obs = '+obsname+' as seen from Moon')
		openw,34,strcompress('titelstring.'+obsname,/remove_all)
		printf,34,tit_str
		close,34
		doy=fix(julday(mm,dd,yy)-julday(12,31,yy-1))
		time=hour+min/60.d0+sec/3600.d0
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
			map_set,latitude,longitude,0,/satellite,sat_p=[distance,0,0],title=tit_str,/isotropic
			;map_set,/mollweide,title=strcompress(dat_str+': '+obsname)
			map_continents,/overplot,title=title,/fill,color=220
			get_image_to_wrap,jd,image
			contour,image,indgen(360),indgen(181)-90,/overplot,/cell_fill,levels=indgen(25)/24.*256
			for longitude=0,359,5 do begin
				for latitude=-90,90,5 do begin
					; for point lon,lat checkif Moon and SUn are both vissible
					MOONPOS, jd, ra_moon, dec_moon, dis
					eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon, lat=latitude, lon=longitude
					SUNPOS, jd, ra_sun, dec_sun
				        eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha, lat=latitude, lon=longitude
					if (alt_moon gt 0.0 and alt_sun gt 0.0) then begin
						; OK so Sun and Moon are vissible from or iluminating that point
						plots,longitude,latitude,psym=7,color=255
						printf,33,longitude,latitude
					endif
				endfor
			endfor
			map_continents,/overplot,title=title,color=255,mlinethick=2
			im=tvrd()
			write_jpeg,strcompress('Moonview'+string(jd)+obsname+'.jpg',/remove_all),im
		endif	; end of if moon vissible
		close,33
	endfor	; iobs loop
endfor	; jd loop
end

