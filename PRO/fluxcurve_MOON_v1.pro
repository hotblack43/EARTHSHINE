 PRO get_filtername,header,name
 ;
 idx=where(strpos(header, 'DMI_COLOR_FILTER') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 name=strcompress(strmid(str,29,8),/remove_all)
 return
 end

PRO MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun,obsname
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

 PRO get_everything_fromJD,JD,phase,am
 common filehandles,abekat
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 ; get the phase and azimuth
 MOONPHASE,jd,phase,alt_moon,alt_sun,obsname
 ; get the airmass
 moonpos, JD, RAmoon, DECmoon
 am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
 ; get the longlint
;get_sunglintpos,jd,longlint,glat,az_moon,alt_moon,moonlat,moonlong
;get_lun,abekat
;openw,abekat,'mapme.dat',/append
;printf,abekat,longlint,glat
;close,abekat
;free_lun,abekat
 return
 end

 FUNCTION get_JD_from_filename,name
 liste=strsplit(name,'/',/extract)
 idx=strpos(liste,'24')
 ipoint=where(idx eq 0)
 JD=double(liste(ipoint))
 return,JD
 end

bias=readfits('TTAURI/superbias.fits')
path='/media/thejll/OLDHD/MOONDROPBOX/'
files=file_search(path,'*245*MOON_*fit*',count=n)
ctmin=8000
openw,30,'fluxcurve_B.dat'
openw,31,'fluxcurve_V.dat'
openw,32,'fluxcurve_VE1.dat'
openw,33,'fluxcurve_VE2.dat'
openw,34,'fluxcurve_IRCUT.dat'
for i=0,n-1,1 do begin
	im=readfits(files(i),header,/sil)
	JD=get_JD_from_filename(files(i))
	get_everything_fromJD,JD,phase,airm
        get_info_from_header,header,'EXPOSURE',exptime
        get_filtername,header,filtername
	l=size(im)
	flux=[]
	ic=0
	if (l(0) eq 2) then begin
		if (max(im-bias) gt ctmin) then begin
			flux=total(im-bias)/exptime
			ic=1
			nims=1
		endif
	endif
	if (l(0) eq 3) then begin
		nims=l(3)
		flux=[]
		ic=0
		for j=0,nims-1,1 do begin
		if (max(im(*,*,j)-bias) gt ctmin) then begin
			flux=[flux,total((im(*,*,j)-bias))/exptime] 
			ic=ic+1
		endif
		endfor
	endif
	fmt='(f15.7,3(1x,g13.6))'
	fmt2='(i5,1x,f15.7,4(1x,g13.6),1x,a)'
	if (ic ne 0) then begin
	print,format=fmt2,i,JD,phase,airm,nims,mean(flux),filtername
	if (filtername eq 'B') then printf,30,format=fmt,JD,phase,airm,mean(flux)
	if (filtername eq 'V') then printf,31,format=fmt,JD,phase,airm,mean(flux)
	if (filtername eq 'VE1') then printf,32,format=fmt,JD,phase,airm,mean(flux)
	if (filtername eq 'VE2') then printf,33,format=fmt,JD,phase,airm,mean(flux)
	if (filtername eq 'IRCUT') then printf,34,format=fmt,JD,phase,airm,mean(flux)
	endif
endfor
close,/all
end

