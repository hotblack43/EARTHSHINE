PRO getearthimage,jd,lon,lat,avgalbedo
;--------------------------------------------------------------------------------------
; Will generate a picture of the Earth as seen from the Moon at a certain input time
; will show day(nigt effects
; will use NCEP 4xdaily tcdc cloud cover
; First generate the map of intensities to show
; Need a land-sea map to generate a sea-land type albedo map
get_land_sea,lon,lat,landseamask
idx=where(landseamask eq -1)
landseamask(idx)=1
maptoshow=0.05+0.10*landseamask
; need the cloud map
get_tcdc_2010_2012,jd,cloud,lonX,latX
if (total(lon - lonX) ne 0 or total(lat ne lat) ne 0) then stop
cloud=cloud/100.
maptoshow=cloud*0.8+(1.-cloud)*maptoshow
; need the day-night map
; also,  get and apply the 'seen from the Moon' mask
SUNPOS, jd, ra_sun, dec_sun
MOONPOS, jd, ra_moon, dec_moon, dist
print,'Distance to Moon: ',dist,' km.'
for i=0,N_ELEMENTS(LON)-1,1 DO BEGIN
for J=0,N_ELEMENTS(LAT)-1,1 DO BEGIN
eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha, lon=lonX(i),lat=latX(j)
eq2hor, ra_moon, dec_moon, jd, alt_moon, az, ha, lon=lonX(i),lat=latX(j)
if (alt_sun lt 0 or alt_moon lt 0) then maptoshow(i,j)=0.0
maptoshow(i,j)=maptoshow(i,j)*sin(alt_sun*!dtor)	; illumination effect
endfor
endfor
; get the view point
get_lon_lat_for_moon_at_zenith,seenfromlon,seenfromlat
rotangle=0
distancetomoon=dist/6371.0
; Then show that map wrapped on a sphere as seen from the Moon
map_set,/advance,/satellite,seenfromlat,seenfromlon,rotangle,sat_p=[distancetomoon,0,0],/isotropic
contour,maptoshow,lon,lat,/overplot,/cell_fill,nlevels=11
map_continents,/overplot
; getthe average albedo of the sunlit piels
avgalbedo=avg(maptoshow(where(maptoshow ne 0)))
return
end

;;....
;common time,jd
; define jd=....
;get_tcdc_2010_2012,jd,map,lon,lat
;getearthimage,jd,lon,lat
;.........
pro sunglint,doy,time,lat,lon,alt,glat,glon,gnadir,gaz
print,'doy,time,lat,lon,alt:',doy,time,lat,lon,alt
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
PRO get_lon_lat_for_moon_at_zenith,lon,lat
; routine for using POWELL to find where the Moon is overhead on Earth
print,'Using POWELL'
; Define the fractional tolerance:
   ftol = 1.0d-8
   ; Define the starting point:
   P = [0.0d0,0.0d0]
   ; Define the starting directional vectors in column format:
   xi = TRANSPOSE([[1.0, 0.0],[0.0, 1.0]])
   ; Minimize the function:
   POWELL, P, xi, ftol, fmin, 'zenithangmoon',/DOUBLE
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
        get_lon_lat_for_moon_at_zenith,longitude,latitude
        altitude=(dis-6371.d0);   /1000.0d0     ;km
        moonlat=latitude(0)
        moonlong=longitude(0)
        sunglint,doy(0),time(0),moonlat,moonlong,altitude(0),glat,glon,gnadir,gaz
return
end


;------------------------------------------------------------------------------------------------------
; Code that collects and summarizes all earthshine results (well, most ...) and plots nice pictures
;------------------------------------------------------------------------------------------------------
common time,jd
openw,88,'thelightcurve.dat'
; generate list to search
spawn,"find /data/pth/DARKCURRENTREDUCED/SELECTED_1/ -name '24*.fits' > allfiles"
file='FORHANS/Chris_list_good_images.txt'
openr,1,file
while not eof(1) do begin
str=''
readf,1,str
print,str
spawn,'rm foundfiles'
spawn,'grep '+str+' allfiles > foundfiles'
if (file_test('foundfiles') eq 1) then begin
openr,2,'foundfiles'
line=''
ic=0
while not eof(2) do begin
readf,2,line
if (ic eq 0) then list=line
if (ic gt 0) then list=[list,line]
ic=ic+1
endwhile
close,2
print,list
!P.MULTI=[0,2,4]
!P.CHARSIZE=1.2
;.............................
; First the RAW image
mdx=strpos(list,'ELECTED_1/24')
klx=where(mdx ne -1)
if (klx(0) ne -1) then begin
print,'The RAW image is in location ',klx(0),' on the list'
raw=readfits(list(klx(0)),rawheader)
contour,xstyle=3,ystyle=3,/cell_fill,nlevels=21,raw,/isotropic,title='uncorrected '+str
contour,xstyle=3,ystyle=3,hist_equal(raw),/cell_fill,nlevels=21,/isotropic,title='uncorrected '+str
endif
;.............................
; then the EFM image
idx=strpos(list,'EFM')
klx=where(idx ne -1)
if (klx(0) ne -1) then begin
print,'The EFM image is in location ',klx(0),' on the list'
efm=readfits(list(klx(0)),efmheader)
;contour,xstyle=3,ystyle=3,/cell_fill,nlevels=21,efm,/isotropic,title='EFM '+str
contour,xstyle=3,ystyle=3,hist_equal(efm),/cell_fill,nlevels=21,/isotropic,title='EFM '+str
endif
;.............................
; then the _LOG image
jdx=strpos(list,'_LOG')
klx=where(jdx ne -1)
if (klx(0) ne -1) then begin
print,'The _LOG image is in location ',klx(0),' on the list'
loga=readfits(list(klx(0)),efmheader)
;contour,xstyle=3,ystyle=3,/cell_fill,nlevels=21,loga,/isotropic,title='LOG '+str
contour,xstyle=3,ystyle=3,hist_equal(loga),/cell_fill,nlevels=21,/isotropic,title='LOG '+str
endif
;.............................
; then the BBSO linear  image
kdx=strpos(list,'BBSO_CLEANED/')
klx=where(kdx ne -1)
if (klx(0) ne -1) then begin
print,'The BBSO linear  image is in location ',klx(0),' on the list'
lin=readfits(list(klx(0)),efmheader)
;contour,xstyle=3,ystyle=3,/cell_fill,nlevels=21,lin,/isotropic,title='LIN '+str
contour,xstyle=3,ystyle=3,hist_equal(lin),/cell_fill,nlevels=21,/isotropic,title='LIN '+str
endif
;.............................

endif else begin
print,'Files not found'
endelse
; show the Earth at the moment of observation as seen from the Moon
get_info_from_header,rawheader,'FRAME',JD
get_info_from_header,rawheader,'DMI_COLOR_FILTER',filter
get_info_from_header,rawheader,'UNSTTEMP',temp
get_info_from_header,rawheader,'EXPOSURE',req_exptime
;maketheearthpicture,jd,glon,glat
get_tcdc_2010_2012,jd,map,lon,lat
getearthimage,jd,lon,lat,avgalbedo
; print 'alebdo information'
printf,88,format='(f15.7,1x,f9.4)',jd,avgalbedo
print,format='(f15.7,1x,f9.4)',jd,avgalbedo
get_sunglintpos,jd,glon,glat,x1,x2,x3,x4
;gofixtheglon,glon
xyouts,/normal,0.1,0.22,'Filter: '+string(filter)
xyouts,/normal,0.1,0.20,'Requested Exp time: '+string(req_exptime)
xyouts,/normal,0.1,0.18,'CCD temperature: '+string(temp)
xyouts,/normal,0.1,0.16,'JD: '+string(JD)
xyouts,/normal,0.1,0.14,'Sunglint lon: '+string(glon,format='(f7.1)')
xyouts,/normal,0.1,0.12,'Sunglint lat: '+string(glat,format='(f7.1)')
jpgname=strcompress(string(jd,format='(f15.7)')+'.jpg',/remove_all)
print,jpgname
write_jpeg,jpgname,tvrd()
print,'---------------------------'
endwhile
close,1
close,88
end
