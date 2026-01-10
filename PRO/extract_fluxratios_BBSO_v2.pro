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

PRO swapem,x,y,xx,yy
dummy=y
y=x
x=dummy
dummy=yy
ayy=xx
xx=dummy
return
end

PRO get_BBSOalbedos,JD,DCRalbedo,del_DCRalbedo,LINalbedo,del_LINalbedo,LOGalbedo,del_LOGalbedo,iflag
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
DS_obs=(pth_median(DCR(idx)))(0)
DS_ideal=(pth_median(ideal(idx)))(0)
DS_BBSOlin=(pth_median(BBSOlin(idx)))(0)
DS_BBSOlog=(pth_median(BBSOlog(idx)))(0)
BS_obs=(pth_median(DCR(jdx)))(0)
BS_ideal=(pth_median(ideal(jdx)))(0)
BS_BBSOlin=(pth_median(BBSOlin(jdx)))(0)
BS_BBSOlog=(pth_median(BBSOlog(jdx)))(0)
;
delta_DS_obs=(pth_median(DCR(idx)))(1)
delta_DS_ideal=(pth_median(ideal(idx)))(1)
delta_DS_BBSOlin=(pth_median(BBSOlin(idx)))(1)
delta_DS_BBSOlog=(pth_median(BBSOlog(idx)))(1)
delta_BS_obs=(pth_median(DCR(jdx)))(1)
delta_BS_ideal=(pth_median(ideal(jdx)))(1)
delta_BS_BBSOlin=(pth_median(BBSOlin(jdx)))(1)
delta_BS_BBSOlog=(pth_median(BBSOlog(jdx)))(1)
;
if (DS_obs gt BS_obs) then swapem,DS_obs,BS_obs,delta_DS_obs,delta_BS_obs
if (DS_ideal gt BS_ideal) then swapem,DS_ideal,BS_ideal,delta_DS_ideal,delta_BS_ideal
if (DS_BBSOlin gt BS_BBSOlin) then swapem,DS_BBSOlin,BS_BBSOlin,delta_DS_BBSOlin,delta_BS_BBSOlin
if (DS_BBSOlog gt BS_BBSOlog) then swapem,DS_BBSOlog,BS_BBSOlog,delta_DS_BBSOlog,delta_BS_BBSOlog

	rel_albedo_DCR=(DS_obs/BS_obs)/(DS_ideal/BS_ideal)
	delta_rel_albedo_DCR=errorvalue(DS_obs,BS_obs,DS_ideal,BS_ideal,delta_DS_obs,delta_BS_obs,delta_DS_ideal,delta_BS_ideal)
	rel_albedo_lin=(DS_BBSOlin/BS_BBSOlin)/(DS_ideal/BS_ideal)
	delta_rel_albedo_lin=errorvalue(DS_BBSOlin,BS_BBSOlin,DS_ideal,BS_ideal,delta_DS_BBSOlin,delta_BS_BBSOlin,delta_DS_ideal,delta_BS_ideal)
        rel_albedo_log=(DS_BBSOlog/BS_BBSOlog)/(DS_ideal/BS_ideal)
	delta_rel_albedo_log=errorvalue(DS_BBSOlog,BS_BBSOlog,DS_ideal,BS_ideal,delta_DS_BBSOlog,delta_BS_BBSOlog,delta_DS_ideal,delta_BS_ideal)


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
 
 JD='2456091.1056433'
 openr,1,'list2'
 JD=''
 openw,56,'BBSO_lin_log_DCR_albedos.dat'
 while not eof(1) do begin
 readf,1,JD
 getphasefromJD,JD,phase
 mphase,JD,k
 get_BBSOalbedos,JD,DCRalbedo,delta_DCRalbedo,LINalbedo,delta_LINalbedo,LOGalbedo,delta_LOGalbedo,iflag
 if (iflag ne 0) then printf,56,format='(f15.7,6(1x,f9.5),1x,f6.1,1x,f6.3)',JD,DCRalbedo,delta_DCRalbedo,LINalbedo,delta_LINalbedo,LOGalbedo,delta_LOGalbedo,phase,k
 if (iflag ne 0) then print,format='(f15.7,6(1x,f9.5),1x,f6.1,1x,f6.3)',JD,DCRalbedo,delta_DCRalbedo,LINalbedo,delta_LINalbedo,LOGalbedo,delta_LOGalbedo,phase,k
 if (iflag eq 0) then print,'Skipping ',JD
 endwhile
 close,1
 close,56
 end
 
