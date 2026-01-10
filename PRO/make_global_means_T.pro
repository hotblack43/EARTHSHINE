;+
; programme to calculate mean land, se and land+sea layer thicknesses in GLIMPSE data
;-
device,decomposed=0
loadct,39
;
file='C:\RSI\WORK\LSM.nc'
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon_lsm
NCDF_VARGET, id, 'lat',    lat_lsm
NCDF_VARGET, id, 'var172',   lsm
NCDF_CLOSE,  id
print,'Done!'
;
file='C:\rSI\WORK\Z500_1500-2000.nc'
ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lev',    level
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon
nlon=n_elements(lon)*1.0
NCDF_VARGET, id, 'lat',    lat
nlat=n_elements(lat)*1.0
NCDF_VARGET, id, 'time',   time
NCDF_VARGET, id, 'var156',   Z500
NCDF_CLOSE,  id
print,'Done!'
file='C:\rSI\WORK\Z200_1500-2000.nc'
ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lev',    level
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon
nlon=n_elements(lon)*1.0
NCDF_VARGET, id, 'lat',    lat
nlat=n_elements(lat)*1.0
NCDF_VARGET, id, 'time',   time
NCDF_VARGET, id, 'var156',   Z200
NCDF_CLOSE,  id
print,'..and Done!'
;
air=reform(Z200-Z500)/28.0	; air temperature calculated from layer thickness and with an empirical constant (from NCEP)
Z200=0
Z500=0
;
ntime=501
air=REBIN(air,128,64,501)	; rebin to annual mean data
;
weight=dblarr(nlon,nlat)
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
weight(ilon,ilat)=cos(lat(ilat)/360.*2.*!pi)
endfor
endfor

;
mean_land=dblarr(ntime)
mean_sea=dblarr(ntime)
mean_global=dblarr(ntime)
; LAND & SEA averages
idx=where(lsm eq 1)
jdx=where(lsm eq 0)
for i=0,ntime-1,1 do begin
	slice=reform(air(*,*,i))
	mean_land(i)=total(slice(idx)*weight(idx))/total(weight(idx))
	mean_sea(i)=total(slice(jdx)*weight(jdx))/total(weight(jdx))
	mean_global(i)=total(slice*weight)/total(weight)
endfor


!P.MULTI=[0,1,4]

plot,mean_land-273.15,xtitle='Year',ytitle='Mean weighted land T',charsize=2,ystyle=1
plot,mean_sea-273.15,xtitle='Year',ytitle='Mean weighted ocean T',charsize=2,ystyle=1
plot,mean_global-273.15,xtitle='Year',ytitle='Ocean T/Land T',charsize=2,ystyle=1
plot,mean_land/mean_sea,xtitle='Year',ytitle='Land T/Sea T',charsize=2,ystyle=1
openw,11,'Land_Sea_LandSea_GLIMPSE_500-200HPa.dat'
for i=0,ntime-1,1 do begin
printf,11,format='(i5,3(1x,f7.2))',i+1500,mean_land(i)-273.15,mean_sea(i)-273.15,mean_global(i)-273.15
print,format='(i5,3(1x,f7.2))',i+1500,mean_land(i)-273.15,mean_sea(i)-273.15,mean_global(i)-273.15

endfor
close,11

end