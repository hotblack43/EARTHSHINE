@stuff19.pro
 PRO getcoordsfromheader,header,x0,y0,radius
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCX0 not in header. Assigning dummy value'
     x0=256.
     endif else begin
     x0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCY0 not in header. Assigning dummy value'
     y0=256.
     endif else begin
     y0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     radius=float(strmid(header(jdx),15,9))
     endelse
 return
 end

 PRO getFILTERNAMEfromfilename,str,filtername,filternum
bits=strsplit(str,'/',/extract)
idx=where(strpos(bits,'24') eq 0)
name=bits(idx)
part=strsplit(name,'_',/extract)
filtername=part(1)
if (filtername eq 'B') then filternum=1
if (filtername eq 'V') then filternum=2
if (filtername eq 'VE1') then filternum=3
if (filtername eq 'VE2') then filternum=4
if (filtername eq 'IRCUT') then filternum=5
 return
 end

 PRO MOONPHASE,jd,az_moon,phase_angle_M,alt_moon,alt_sun,obsname
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

 PRO get_everything_fromJD,JD,phase,azimuth,am,longlint,glat
 common filehandles,abekat
 ;print,'in get_everything_fromJD, jd is: ',jd
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 alt_moon=[]
 alt_sun=[]
 azimuth=[]
 az_moon=[]
 glat=[]
 longlint=[]
 moonlat=[]
 moonlong=[]
 phase=[]
 azimuth=[]
 am=[]

 ; get the phase and azimuth
 for i=0,n_elements(jd)-1,1 do begin
 MOONPHASE,jd(i),azimuth_o,phase_o,alt_moon_o,alt_sun_o,obsname
 ; get the airmass
 moonpos, JD(i), RAmoon, DECmoon
 am_o = airmass(JD(i), RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
 ; get the longlint
 get_sunglintpos,jd(i),longlint_o,glat_o,az_moon_o,alt_moon_o,moonlat_o,moonlong_o
;
 alt_moon=[alt_moon,alt_moon_o]
 alt_sun=[alt_sun,alt_sun_o]
 azimuth=[azimuth,azimuth_o]
 glat=[glat,glat_o]
 longlint=[longlint,longlint_o]
 moonlat=[moonlat,moonlat_o]
 moonlong=[moonlong,moonlong_o]
 phase=[phase,phase_o]
 am=[am,am_o]
 endfor
 return
 end

;---------------------------------------------------------------
; Will generate and collect information about single FITS files and the fit to these
;...............................................
filtername=['']
filternum=[]
exptime=[]
radius=[]
X0=[]
Y0=[]
illfrac=[]
file='CLEM.DMI.profiles_fitted_results_SELECTED_5_multipatch_contrFIX_stacks_17May2014.txt'
spawn,"awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' "+file+" > liste.dat"
spawn,"awk '{print $1,$13}' "+file+" > JD_filenames.txt"
data=get_data('liste.dat')
JD=reform(data(00,*))
albedo=reform(data(01,*))
albedoerr=reform(data(02,*))
alfa1=reform(data(03,*))
rlimit=reform(data(04,*))
pedestal=reform(data(05,*))
xshift=reform(data(06,*))
yshift=reform(data(07,*))
corefactor=reform(data(08,*))
contrast=reform(data(09,*))
RMSE=reform(data(10,*))
totfl=reform(data(11,*))
for i=0,n_elements(JD)-1,1 do begin
spawn,"grep "+string(jd(i),format='(f15.7)')+" JD_filenames.txt | awk '{print $2}' > namfil"
str=''
openr,56,'namfil'
readf,56,str
close,56
im=readfits(str,h,/silent)
getcoordsfromheader,h,x0_o,y0_o,radius_o
get_info_from_header,h,'EXPOSURE',exptime_o
mphase,jd(i),illfrac_o
getFILTERNAMEfromfilename,str,filtername_o,filternum_o
fnamfiiiltername=[filtername,filtername_o]
filternum=[filternum,filternum_o]
exptime=[exptime,exptime_o]
radius=[radius,radius_o]
X0=[X0,X0_o]
Y0=[Y0,Y0_o]
illfrac=[illfrac,illfrac_o]
endfor
;
get_everything_fromJD,JD,ph,azi,airm,longlint,glat
fmtstr='(f15.7,10(1x,f12.5),1x,i2,8(1x,f12.5),1x,f20.3)'
explainstr='preliminary_v1'
openw,78,'MASTERlist_results_'+explainstr+'.txt'
for i=0,n_elements(jd)-1,1 do begin
print,format=fmtstr,jd(i),albedo(i),albedoerr(i),alfa1(i),rlimit(i),pedestal(i),xshift(i),yshift(i),corefactor(i),RMSE(i),exptime(i),filternum(i),ph(i),airm(i),longlint(i),glat(i),x0(i),y0(i),radius(i),illfrac(i),totfl(i)
printf,78,format=fmtstr,jd(i),albedo(i),albedoerr(i),alfa1(i),rlimit(i),pedestal(i),xshift(i),yshift(i),corefactor(i),RMSE(i),exptime(i),filternum(i),ph(i),airm(i),longlint(i),glat(i),x0(i),y0(i),radius(i),illfrac(i),totfl(i)
endfor
close,78
openw,78,'MASTERlist_results_'+explainstr+'.header'
printf,78,'JD,albedo,albedoerr,alfa1,rlimit,pedestal,xshift,yshift,corefactor,RMSE,exptime,filternum,ph,airm,longlint,glat,x0,y0,radius,illfrac,totfl'
close,78
end
