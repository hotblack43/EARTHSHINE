PRO get_all_data,hgt_level,lon,lat,height,fracyear_hgt,air_level,air,fracyear_air,mean_Temp_500_200,thickness_500_200
file1='/home/pth/SCIENCEPROJECTS/WORK/nc_files/hgt.mon.mean.nc'
id = NCDF_OPEN(file1)
NCDF_VARGET, id, 'level',    hgt_level
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'hgt',   height
NCDF_VARGET, id, 'time',   time
NCDF_CLOSE,  id
idx=where(height lt -9.9e30)
if (idx(0) ne -1) then stop
jd=julday(1,1,1)+time/24.
caldat,jd,mm,dd,yy
fracyear_hgt=yy+(mm-1)/12.+(dd+15.)/365.25
l=size(height,/dimensions)
print,l
nlon=l(0)
nlat=l(1)
nlevels=l(2)
ntime=l(3)
openw,44,'hgt.bin'
writeu,44,nlon
writeu,44,lon

writeu,44,nlat
writeu,44,lat

writeu,44,nlevels
writeu,44,hgt_level

writeu,44,ntime
writeu,44,jd
writeu,44,fracyear_hgt
writeu,44,height
close,44
help,height
print,'wrote out binary file for hgt...'
;
file1='/home/pth/SCIENCEPROJECTS/WORK/nc_files/air.mon.mean.nc'
ncdf_cat,file1
id = NCDF_OPEN(file1)
NCDF_VARGET, id, 'level',    air_level
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'air',   air
idx=where(air eq 32766)
if (idx(0) ne -1) then stop
air=air*0.01+127.650
print,'scaled air..'
NCDF_VARGET, id, 'time',   time
NCDF_CLOSE,  id
jd=julday(1,1,1)+time/24.
caldat,jd,mm,dd,yy
fracyear_air=yy+(mm-1)/12.+(dd+15.)/365.25
l=size(air,/dimensions)
print,l
nlon=l(0)
nlat=l(1)
nlevels=l(2)
ntime=l(3)
openw,44,'air.bin'
writeu,44,nlon
writeu,44,lon

writeu,44,nlat
writeu,44,lat

writeu,44,nlevels
writeu,44,air_level

writeu,44,ntime
writeu,44,jd
writeu,44,fracyear_air
writeu,44,air
help,air
close,44
print,'wrote out binary file for air...'
; calculate layer thickness
idx=where(hgt_level eq 500)
surface_500=reform(height(*,*,idx,*))
idx=where(hgt_level eq 200)
surface_200=reform(height(*,*,idx,*))
thickness_500_200=surface_200-surface_500
; calculate weighted mean layer temperature
idx=where(air_level ge 200 and air_level le 500)
weight=alog(air_level(idx))
l=size(air,/dimensions)
nlon=l(0)
nlat=l(1)
nlevel=l(2)
ntime=l(3)
mean_Temp_500_200=fltarr(nlon,nlat,ntime)
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
for itime=0,ntime-1,1 do begin
mean_Temp_500_200(ilon,ilat,itime)=total(weight*air(ilon,ilat,idx,itime))/total(weight)
endfor
endfor
endfor

return
end

get_all_data,hgt_level,lon,lat,height,fracyear_hgt,air_level,air,fracyear_air,mean_Temp_500_200,thickness_500_200

help
end
