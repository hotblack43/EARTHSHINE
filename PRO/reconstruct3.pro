
; Version 3. Will calibrate proxies during a period only, but try to reconstruct whole
; Uses backwards elimination to select significant regressors

device='ps
set_plot,device
if (device eq 'X') then device,decomposed=0
if (device eq 'ps') then begin
device,/color
device,xsize=18,ysize=24.5,yoffset=2
endif
loadct,9
;
;
year_calib_start=300
year_calib_stop=399
;
nrandom=30		; number of randomly scattered positions for proxies
ntest=3
file='/home/pth/Desktop/WORK/DATA/LSM.nc'
lon_lsm=0L
lat_lsm=0L
lsm=0L
id = NCDF_OPEN(file)
help,id,lon_lsm
print,NCDF_VARID(id,'lon')
NCDF_VARGET, id, 'lon',    lon_lsm
print,'Hej'
NCDF_VARGET, id, 'lat',    lat_lsm
NCDF_VARGET, id, 'var172',   lsm
NCDF_CLOSE,  id
print,'Done!'
;
file='/home/pth/Desktop/WORK/DATA/SST_1500-2000.nc'
ncdf_cat,file
id = NCDF_OPEN(file)
lon=0
lat=0
time=0
NCDF_VARGET, id, 'lon',    lon
nlon=n_elements(lon)*1.0
NCDF_VARGET, id, 'lat',    lat
nlat=n_elements(lat)*1.0
NCDF_VARGET, id, 'time',   time
year=fix(time/10000.)
rest=time-year*10000L
month=fix(rest/100.)
fracyear=year+(month-0.5)/12.
NCDF_VARGET, id, 'var139',   SST
NCDF_CLOSE,  id
print,'Done!'
;

;
ntime=501
SST=REBIN(SST,128,64,501)	; rebin to annual mean data
;SST=SST*0.+1.+273.15
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
	slice=reform(sst(*,*,i))
	mean_land(i)=total(slice(idx)*weight(idx))/total(weight(idx))
	mean_sea(i)=total(slice(jdx)*weight(jdx))/total(weight(jdx))
	mean_global(i)=total(slice*weight)/total(weight)
endfor


!P.MULTI=[0,1,1]

;plot,mean_land-273.15,xtitle='Year',ytitle='Mean weighted land T',charsize=2,ystyle=1
;plot,mean_sea-273.15,xtitle='Year',ytitle='Mean weighted ocean T',charsize=2,ystyle=1
plot,mean_global-273.15,xtitle='Year',ytitle='Mean weighted global T',charsize=2,ystyle=1
plots,[year_calib_start,year_calib_start],[!Y.crange]
plots,[year_calib_stop,year_calib_stop],[!Y.crange]
;plot,mean_land/mean_sea,xtitle='Year',ytitle='Land T/Sea T',charsize=2,ystyle=1
openw,11,'Land_Sea_LandSea.dat'
for i=0,ntime-1,1 do begin
printf,11,format='(i5,3(1x,f7.2))',i+1500,mean_land(i)-273.15,mean_sea(i)-273.15,mean_global(i)-273.15
print,format='(i5,3(1x,f7.2))',i+1500,mean_land(i)-273.15,mean_sea(i)-273.15,mean_global(i)-273.15

endfor
close,11
;----------------------------------
;test1,mean_global,ntime,nrandom,YEAR_CALIB_START,year_calib_stop,IYEARs,ntest,nlat,nlon,SST
 test2,mean_global,ntime,nrandom,YEAR_CALIB_START,year_calib_stop,IYEARs,ntest,nlat,nlon,SST

if (device eq 'ps') then device,/close
end
