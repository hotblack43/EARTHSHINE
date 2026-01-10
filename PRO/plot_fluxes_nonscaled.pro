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

PRO getfluxes,lon,lat,im,DS,BS,TOT
; calculates surface brightness in mags
lon0=-60
lat0=17
w=5
idx=where(lon gt lon0-w and lon lt lon0+w and lat gt lat0-w and lat lt lat0+w)
n1=n_elements(idx)
print,'reg1 n: ',n1
reg1=-2.5*alog10(total(im(idx)))+2.5*alog10(6.67*6.67*n1)
lon0=+60
lat0=-17
w=5
jdx=where(lon gt lon0-w and lon lt lon0+w and lat gt lat0-w and lat lt lat0+w)
n2=n_elements(jdx)
print,'reg2 n: ',n2
reg2=-2.5*alog10(total(im(jdx)))+2.5*alog10(6.67*6.67*n2)
if (reg1 gt reg2) then begin
	DS=reg1
	BS=reg2
endif else begin
	DS=reg2
	BS=reg1
endelse
kdx=where(im gt max(im)/2000.)
imshow=im
imshow(kdx)=max(im)
tvscl,imshow
n3=n_elements(kdx)
print,'reg3 n: ',n3
tot=-2.5*alog10(total(im(kdx)))+2.5*alog10(6.67*6.67*n3)
return
end

files=file_search('*mixed117*scale*.fit*',count=n)
openw,33,'p.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),/sil)
jd=strmid(files(i),strpos(files(i),'245'),15)
lonlatexist=file_test('/data/pth/UNIVERSALSETOFMODELS/lonlat*'+jd+'*')
if (lonlatexist eq 1) then begin
lonlatfilname=file_search(strcompress('/data/pth/UNIVERSALSETOFMODELS/lonlat*'+jd+'*',/remove_all))
lonlat=readfits(lonlatfilname(0),/sil)
lon=reform(lonlat(*,*,0))
lat=reform(lonlat(*,*,1))
; get and print mags
getfluxes,lon,lat,im,DS,BS,TOT
;print,format='(f15.7,3(1x,f15.5))',jd,DS,BS,TOT
printf,33,format='(f15.7,3(1x,f15.5))',jd,DS,BS,TOT
endif
endfor
close,33
data=get_data('p.dat')
jd=reform(data(0,*))
n=n_elements(jd)
phase_angle_M=fltarr(n)
obsname='mlo'
for k=0,n-1,1 do begin
	MOONPHASE,jd(k),ph,alt_moon,alt_sun,obsname
	phase_angle_M(k)=ph
endfor
ds=reform(data(1,*))
bs=reform(data(2,*))
tot=reform(data(3,*))
!P.MULTI=[0,2,3]
!P.CHARSIZE=1.4
!P.THICK=3
!x.THICK=2
!y.THICK=2
;----------------------------------------------
ldx=where(phase_angle_M le 0)
plot,xstyle=3,yrange=[8,13],xrange=[-160,-30],xtitle='Lunar phase angle',ytitle='DS [m/asec!u2!n]',phase_angle_M(ldx),ds(ldx),psym=7
ldx=where(phase_angle_M gt 0)
plot,xstyle=3,yrange=[8,13],xrange=[30,160],xtitle='Lunar phase angle',ytitle='DS [m/asec!u2!n]',phase_angle_M(ldx),ds(ldx),psym=7
;----------------------------------------------
ldx=where(phase_angle_M le 0)
plot,/nodata,xstyle=3,yrange=[-2,3],xrange=[-160,-30],xtitle='Lunar phase angle',ytitle='TOT and BS [m/asec!u2!n]',phase_angle_M(ldx),tot(ldx),psym=7
oplot,phase_angle_M(ldx),tot(ldx),psym=7,color=fsc_color('red')
oplot,phase_angle_M(ldx),bs(ldx),psym=7,color=fsc_color('blue')
ldx=where(phase_angle_M gt 0)
plot,/nodata,xstyle=3,yrange=[-2,3],xrange=[30,160],xtitle='Lunar phase angle',ytitle='TOT and BS [m/asec!u2!n]',phase_angle_M(ldx),tot(ldx),psym=7
oplot,phase_angle_M(ldx),tot(ldx),psym=7,color=fsc_color('red')
oplot,phase_angle_M(ldx),bs(ldx),psym=7,color=fsc_color('blue')
;----------------------------------------------
end
