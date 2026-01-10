PRO gofixtheglon,glon
; code to place glon on -180 to 180 degree interval
if (glon gt 180) then begin
	glon=glon-180	; now East of dateline
	glon=-180+glon	; now west of Greenwich
endif
if (glon lt -180) then begin
	glon=glon+180		; west of dateline
	glon=180+glon		; East of Greenwich
endif
return
end


pro sunglint,doy,time,lat,lon,alt,glat,glon,gnadir,gaz
;+
; ROUTINE:	sunglint
;
; PURPOSE:	compute lat-lon of point on earths surface which will
;               reflect sunlight to satellite observation point by 
;               purely specular reflection.
;
; USEAGE:	sunglint,doy,time,lat,lon,alt,glat,glon
;
; INPUT:
;
;   doy		day of year              (scalor)
;   time	time UTC (hours)         (scalor)
;   lat         satellite latitude       (scalor)
;   lon         satellite longitude      (scalor)
;   alt         satellite altitude       (scalor)
;
; OUTPUT
;
;   glat        sunglint latitude
;   glon        sunglint longitude
;   gnadir      sunglint nadir angle
;   gaz         sunglint azimuth
;               
;               if satellite is on the night side 
;               glat and glon are returned as 1000,1000
; 
;   if parameters GLAT, GLON, GNADIR and GAZ are left off the argument
;   list then SUNGLINT prints these parameters to the terminal
;
;
; KEYWORD INPUT:
;
;  
; EXAMPLE:	
;
; sunglint,129,21.5,25,-120,800,glat,glon,gnadir,gaz
; print,f='(4f10.2)',glat,glon,gnadir,gaz
;
; sunglint,80,12,90.0,0,1000              ; sunlat =0 sunlon=0
; sunglint,80,12,90.0,0,10000             ;   note how glat approaches
; sunglint,80,12,90.0,0,100000            ;   45 at alt is increased
; sunglint,80,12,90.0,0,1000000           ; 

;
; REVISIONS:
;
;  author:  Paul Ricchiazzi                           dec 95
;           Institute for Computational Earth System Science
;           University of California, Santa Barbara
;-
;
; if satellite is at theta=0 and sun is at theta=thetasun, then the
; reflection angle, alpha (which is zenith angle of reflected ray at
; reflection point) is equal to
;
;                          sin(theta)
;       alpha = atan ( -------------------)    (comes from law of sines)
;                         cos(theta)-xx
;
; The glint angle is found by setting theta+alpha=thetasun.
; Using the cosine angle sum formula, cos(a+b)=cos(a)*cos(b)-sin(a)*sin(b)
; we derive:
;
;       2mu^2-xx*mu-1
;   -------------------      = mu0
;   sqrt(1-2*mu*xx+xx^2)
;
;  where mu       = cos(theta),
;        theta    = earth centered angle between satellite and glint point
;        xx       = re/(re+h)
;        mu0      = cos(thetasun)
;        thetasun = earth centered angle between satellite and sun
;
;
; sunglint,129,21.5,25,-120,800,glat,glon,gnadir,gaz
; doy=129 & time=21.5 & lat=25 & lon=-120 & alt=800
; doy=80  & time=12   & lat=0. & lon=0.   & alt=1000000000000.
;

zensun,doy,time,lat,lon,z,gaz,latsun=latsun,lonsun=lonsun
compass,lat,lon,latsun,lonsun,rng,az
thetasun=rng/(6371.2d0*!dtor)
h=alt/6371.2d0
xx=1.d0/(1.d0+h)

if thetasun gt 90+acos(xx)/!dtor then begin
  glat=1000
  glon=1000
  gnadir=1000
  gaz=1000
  return
endif

mu=cos(findrng([0,.51d0*thetasun],1000)*!dtor)
f1=2.0d0*mu^2-xx*mu-1.0d0
f2=sqrt(1.d0-2.0d0*mu*xx+xx^2)
func=f1/f2-cos(thetasun*!dtor)
  ; plot,mu,func,/xstyle & oplot,[0,180],[0,0]

ii=where(func*shift(func,-1) lt 0,nc)
if nc eq 0 then message,'no solution'
ii=ii(0)
muse=interpol(mu(ii:ii+1),func(ii:ii+1),0)
amuse=acos(muse)
glintrng=amuse*6371.2d0
theta=amuse/!dtor
  
compass,lat,lon,glintrng,az,glat,glon,/to_latlon
gnadir=thetasun-2*theta


if n_elements(glat) eq 1 then begin
  glat=glat(0)
  glon=glon(0)
endif
if n_params() lt 7 then begin
  print,f='(4a10)','glat','glon','gnadir','gaz'
  print,f='(4f10.2)',glat,glon,gnadir,gaz
endif
end

FUNCTION zenithangMoon,x
common time,jd
longitude=x(0)
latitude=x(1)
        MOONPOS, jd, ra_moon, dec_moon, dis, geolon,geolat
        eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  lon=longitude,lat=latitude
zenithangMoon=90.-alt_moon
return,zenithangMoon
end

PRO get_lon_lat_for_Moon_at_zenith,lon,lat
; routine for using POWELL to find where the Moon is overhead on Earth
print,'Using POWELL'
; Define the fractional tolerance:
   ftol = 1.0d-8
   ; Define the starting point:
   P = [0.0d0,0.0d0]
   ; Define the starting directional vectors in column format:
   xi = TRANSPOSE([[1.0, 0.0],[0.0, 1.0]])
   ; Minimize the function:
   POWELL, P, xi, ftol, fmin, 'zenithangMoon',/DOUBLE
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
        get_lon_lat_for_Moon_at_zenith,longitude,latitude
        altitude=(dis-6371.d0);   /1000.0d0     ;km
        moonlat=latitude(0)
        moonlong=longitude(0)
        sunglint,doy,time,moonlat,moonlong,altitude,glat,glon,gnadir,gaz
return
end


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Code to plot existing lunar images' sunglint coordinates on a map
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
openw,44,'sunglint.coords'
openr,2,'Chris_list_good_images.txt'	; file of JDs
ic=0
while not eof(2) do begin
b=0.0d0
readf,2,b
jd=b;	double(strmid(b,0,14))
get_sunglintpos,jd,glon,glat,az_moon,alt_moon,moonlat,moonlong
gofixtheglon,glon
if (ic eq 0) then begin
map_set,londel=10,latdel=10,limit=[-40,-180,40,180],/isotropic
map_continents,/overplot
if (az_moon lt 180) then oplot,[glon,glon],[glat,glat],psym=7,color=fsc_color('red')
if (az_moon ge 180) then oplot,[glon,glon],[glat,glat],psym=7,color=fsc_color('green')
endif else begin
if (az_moon lt 180) then oplot,[glon,glon],[glat,glat],psym=7,color=fsc_color('red')
if (az_moon ge 180) then oplot,[glon,glon],[glat,glat],psym=7,color=fsc_color('green')
endelse
mphase,jd,illfrac
printf,44,format='(f19.7,7(1x,f9.2))',jd,glon,glat,az_moon,alt_moon,illfrac,moonlat,moonlong
print,format='(f19.7,7(1x,f9.2))',jd,glon,glat,az_moon,alt_moon,illfrac,moonlat,moonlong
ic=ic+1
endwhile
close,2
close,44
end


