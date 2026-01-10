PRO get_all_data
file1='/home/pth/SCIENCEPROJECTS/WORK/nc_files/hgt.mon.mean.nc'
id = NCDF_OPEN(file1)
NCDF_VARGET, id, 'level',    level
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'hgt',   height
NCDF_VARGET, id, 'time',   time
NCDF_CLOSE,  id
idx=where(height lt -9.9e30)
if (idx(0) ne -1) then stop
jd=julday(1,1,1)+time/24.
caldat,jd,mm,dd,yy
fracyear1=yy+(mm-1)/12.+(dd+15.)/365.25
stop
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
writeu,44,level

writeu,44,ntime
writeu,44,jd
writeu,44,fracyear1
writeu,44,height
close,44
help,height
print,'wrote out binary file for hgt...'
;
file1='/home/pth/SCIENCEPROJECTS/WORK/nc_files/air.mon.mean.nc'
ncdf_cat,file1
id = NCDF_OPEN(file1)
NCDF_VARGET, id, 'level',    level
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
fracyear1=yy+(mm-1)/12.+(dd+15.)/365.25
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
writeu,44,level

writeu,44,ntime
writeu,44,jd
writeu,44,fracyear1
writeu,44,air
help,air
close,44
print,'wrote out binary file for air...'
return
end

get_all_data
end
