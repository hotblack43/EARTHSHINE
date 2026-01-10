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
bias=bias*1.0d0
ctmin=25000L
openr,71,'list14'
fi=0
			fmt='(f15.7,3(1x,f9.4),1x,f9.4,1x,a)'
while not eof(71) do begin
str=''
readf,71,str
	print,'Image #: ',fi
	im=readfits(str,header,/sil)
	im=im*1.0d0
	JD=get_JD_from_filename(str)
	moviestack=[]
	l=size(im)
	print,l
	mask=fltarr(l(1),l(2))*0.0+1.0
	if (l(0) eq 3) then begin
		nims=l(3)
	        avim=median(im,dimension=3)-bias
		ic=0
		iflag=0
	        totfluxarr=[]
		for j=0,nims-1,1 do begin
		subim=im(*,*,j)-bias
		if (max(subim) gt ctmin) then begin
			idx=where(subim gt max(subim)/500.)
			mask(idx)=!values.f_nan
			resim=subim-avim
	                moviestack=[[[moviestack]],[[resim*mask]]]
			totfluxarr=[totfluxarr,total(subim-bias,/double)]
			ic=ic+1
			iflag=314
		endif
		endfor
		if (ic gt 10 and iflag eq 314) then begin
			for k=0,ic-1,1 do begin
				if (max(moviestack(*,*,k),/nan) ne min(moviestack(*,*,k),/nan)) then tvscl,hist_equal(moviestack(*,*,k))
			endfor
			openw,78,'residual_stats.dat',/append
			printf,78,format=fmt,jd,stddev(moviestack,/nan,/double),stddev(moviestack(0:50,0:50,*),/nan,/double),max(im(*,10,*)),stddev(totfluxarr,/nan,/double)/mean(totfluxarr,/double)*100.,str
			print,format=fmt,jd,stddev(moviestack,/nan,/double),stddev(moviestack(0:50,0:50,*),/nan,/double),max(im(*,10,*)),stddev(totfluxarr,/nan,/double)/mean(totfluxarr,/double)*100.,str
close,78
		endif
	endif
fi=fi+1
endwhile
end

