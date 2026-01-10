 PRO get_airmass_fromJD,JD_in,azimuth,am
 JD=double(JD_in)
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 ; get the airmass
 moonpos, JD, RAmoon, DECmoon
 am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
 am=am(0)
;print,'Airmass: ',am
 end

PRO getnumberofframes,header,numframes
idx=strpos(header,'COADDING')
ipoint=where(idx ne -1)
if (ipoint(0) eq -1) then stop
bits=strsplit(header(ipoint),' ',/extract)
numframes=fix(bits(1))
return
end

FUNCTION getratiosofratios,a_in,b_in,c_in,d_in
nMC=1000
liste=[]
for iMC=0,nMC-1,1 do begin
idx=fix(n_elements(a_in)*randomu(seed,n_elements(a_in)))
jdx=fix(n_elements(d_in)*randomu(seed,n_elements(d_in)))
 a=a_in(idx)
 b=b_in(idx)
 c=c_in(idx)
 d=d_in(idx)
 if (median(a) gt median(b)) then swapem,a,b
 if (median(c) gt median(d)) then swapem,c,d
rat=median(a(idx)/c(idx))*median(d(jdx)/b(jdx))
liste=[liste,rat]
endfor
return,[median(liste),robust_sigma(liste)]
end

FUNCTION errorvalue,a,b,c,d,dela,delb,delc,deld
; chain-rule propagation of errors of y=(a/b)/(c/d)
value=sqrt((a*deld/(b*c))^2+(a*d*delc/(b*c^2))^2+(a*d*delb/(b^2*c))^2+(d*dela/(b*c))^2)
return,value
end

FUNCTION pth_median,x
return,[median(x),robust_sigma(x)]
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
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME='mlo';obsname
SUNPOS, jd, ra_sun, DECsun
eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname
RAdiff = ra_moon - ra_sun
sign = +1
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
return
end


PRO getphasefromJD,JD,phase
MOONPHASE,jd(0),phase_angle_M,alt_moon,alt_sun,obsname
phase=phase_angle_M
return
end

PRO swapem,x,y
dummy=y
y=x
x=dummy
return
end

PRO get_BBSOalbedos,JD,DCRalbedo,del_DCRalbedo,LINalbedo,del_LINalbedo,LOGalbedo,del_LOGalbedo,am,iflag
 iflag=0

 fname='/media/thejll/SAMSUNG/EARTHSHINE/UNIVERSALSETOFMODELS/lonlatSELimage_JD'+JD+'.fits'
 if (file_exist(fname) eq 0) then return
 lonlat=readfits(fname,/silent)
 lon=reform(lonlat(*,*,0))
 lat=reform(lonlat(*,*,1))
;
 fname='/media/thejll/SAMSUNG/EARTHSHINE/UNIVERSALSETOFMODELS/ideal_LunarImg_SCA_0p310_JD_'+JD+'.fit'
 if (file_exist(fname) eq 0) then return
 ideal=readfits(fname,/silent)
;
 fname='/media/thejll/OLDHD/ASTRO/EARTHSHINE/data/pth/DARKCURRENTREDUCED/SELECTED_10/'+JD+'MOON_*_AIR_DCR.fits'
 if (file_exist(fname) eq 0) then return
 DCR=readfits(fname,/silent)
 totflx=total(DCR,/double)
 ideal=ideal/total(ideal,/double)*totflx
;
 fname='/media/thejll/OLDHD/ASTRO/EARTHSHINE/data/pth/DARKCURRENTREDUCED/SELECTED_10/BBSO_CLEANED/'+JD+'MOON_*_AIR_DCR.fits'
 if (file_exist(fname) eq 0) then return
 BBSOlin=readfits(fname,header,/silent) 
;
 fname='/media/thejll/OLDHD/ASTRO/EARTHSHINE/data/pth/DARKCURRENTREDUCED/SELECTED_10/BBSO_CLEANED_LOG/'+JD+'MOON_*_AIR_DCR.fits'
	if (file_exist(fname) eq 0) then return
 BBSOlog=readfits(fname,/silent)
;
 gofindradiusandcenter_fromheader,header,x0,y0,radius
 getnumberofframes,header,numframes
 get_airmass_fromJD,JD,azimuth,am
 if (jd-long(jd) lt 0.5) then doflipnsuch,ideal,x0,y0
 if (jd-long(jd) ge 0.5) then doshift,ideal,x0,y0
 doflipnsuch,lon,x0,y0
 doflipnsuch,lat,x0,y0
 lonmin=70.0
 lonmax=80.0
 latlim=40.0
 idx=where(lon gt -lonmax and lon le -lonmin and lat gt -latlim and lat le latlim)
 jdx=where(lon ge +lonmin and lon lt +lonmax and lat gt -latlim and lat le latlim)
 ; make sure DS and BS are identified from data
;
	statarr=getratiosofratios(DCR(idx),DCR(jdx),ideal(idx),ideal(jdx))
	rel_albedo_DCR=statarr(0)
	delta_rel_albedo_DCR=statarr(1)
	statarr=getratiosofratios(BBSOlin(idx),BBSOlin(jdx),ideal(idx),ideal(jdx))
	rel_albedo_lin=statarr(0)
	delta_rel_albedo_lin=statarr(1)
	statarr=getratiosofratios(BBSOlog(idx),BBSOlog(jdx),ideal(idx),ideal(jdx))
        rel_albedo_log=statarr(0)
	delta_rel_albedo_log=statarr(1)


 DCRalbedo=rel_albedo_DCR*0.3
 LINalbedo=rel_albedo_lin*0.3
 LOGalbedo=rel_albedo_log*0.3
 del_DCRalbedo=delta_rel_albedo_DCR*0.3
 del_LINalbedo=delta_rel_albedo_lin*0.3
 del_LOGalbedo=delta_rel_albedo_log*0.3
 iflag=1
 return
 end
 PRO doshift,im,x0,y0
 im=shift(im,x0-256,y0-256)
 return
 end
 PRO doflipnsuch,im,x0,y0
 im=reverse(im)
 im=shift(im,x0-256,y0-256)
 return
 end
 FUNCTION get_JD_from_filename,name
 idx=strpos(name,'24')
 JD=double(strmid(name,idx,15))
 return,JD
 end
 
 PRO gofindradiusandcenter_fromheader,header,x0,y0,radius
 ; Will take a header and read out DISCX0, DISCY0 and RADIUS
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
     radius=float(strmid(header(jdx),11,19))
     endelse
 x0=x0(0)
 y0=y0(0)
 radius=radius(0)
 return
 end
 
 ;-------------------------------------------
 ; 
 close,/all
 openr,1,'list2'
 JD=''
 openw,56,'BBSO_lin_log_DCR_albedos.dat'
 while not eof(1) do begin
 readf,1,JD
 getphasefromJD,JD,phase
 mphase,JD,k
 get_BBSOalbedos,JD,DCRalbedo,delta_DCRalbedo,LINalbedo,delta_LINalbedo,LOGalbedo,delta_LOGalbedo,am,iflag
 fmtstr='(f15.7,6(1x,f9.5),1x,f6.1,1x,f6.3,1x,f10.4)'
 if (iflag ne 0) then printf,56,format=fmtstr,JD,DCRalbedo,delta_DCRalbedo,LINalbedo,delta_LINalbedo,LOGalbedo,delta_LOGalbedo,phase,k,am
 if (iflag ne 0) then print,format=fmtstr,JD,DCRalbedo,delta_DCRalbedo,LINalbedo,delta_LINalbedo,LOGalbedo,delta_LOGalbedo,phase,k,am
 if (iflag eq 0) then print,'Skipping ',JD
 endwhile
 close,1
 close,56
 end
 
