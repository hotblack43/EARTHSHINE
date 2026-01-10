PRO get_albedo,file,albedo,jd,lon,lat
ncdf_cat,file
cdfid = ncdf_open( file )
ncdf_varget, cdfid, 'longitude', lon
ncdf_varget, cdfid, 'latitude', lat
ncdf_varget, cdfid, 'time', time
ncdf_varget, cdfid, 'tcc', tcc
idx=where(tcc eq -32767)
if (idx(0) ne -1) then stop
albedo=tcc*1.5259488e-05+0.49999237
albedo=0.1+avg(avg(albedo,0),0)*0.5
albedo=albedo/1.8
ncdf_close, cdfid
return
end

file='ERAI_albedo_2015.nc'	; cdo daily (?) means of the below
file='/data/pth/NETCDF/_grib2netcdf-atls17-95e2cf679cd58ee9b4db4dd119a05a8d-SNc9xJ.nc'
get_albedo,file,albedo,jd
plot,albedo
help
end
