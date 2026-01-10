PRO get_distance_toSUN,jd,positionstr,distance
 SUNPOS, jd, ra, dec,/RADIAN
;print,'Sun is at: ',ra,dec,' in radians.'
 hh=strmid(positionstr,0,2)
 mm=strmid(positionstr,2,2)
 ss=strmid(positionstr,5,5)
 deg=strmid(positionstr,12,3)
 min=strmid(positionstr,15,2)
 sec=strmid(positionstr,18,4)
 ra_planet=ten(hh,mm,ss)/24.*!pi*2.
 dec_planet=ten(deg,min,sec)/360.*!pi*2.
;print,'Planet is at: ',ra_planet,dec_planet,' in radians.'
 gcirc,0,ra,dec,ra_planet,dec_planet,distance
	distance=distance/(2.*!pi)*360.	; in degrees
 return
 end
 
 
 planets=['Moon','Mercury','Venus','Mars','Jupiter','Saturn']
 nplanets=n_elements(planets)
 for iplanet=1,nplanets,1 do begin
 planet=planets(iplanet-1)
 safelimit=15	; degrees to the SUN!
 file=file_search(strcompress('PLANETS/'+planet+'.positions',/remove_all))
 print,file
 openr,1,file
 openw,3,strcompress(file+'.SAFE',/remove_all)
 while not eof(1) do begin
     s=''
     readf,1,s
     if (s eq '$$SOE') then begin
	k=''
	while (k ne '$$EOE') do begin
         readf,1,k
	if (strpos(k,'Airmass') eq -1 and strlen(strcompress(k,/remove_all)) gt 2) then begin
         JD=double(strmid(k,19,16))
         positionstr=strmid(k,42,22)
         get_distance_toSUN,jd,positionstr,distance
;print,'Sun-Planet distance in degrees: ',distance
         if (distance gt safelimit) then printf,3,format='(a10,1x,a,1x,f4.1)',planet,k,distance
endif
         endwhile
	endif
     endwhile
 close,1
close,3
endfor
 end
