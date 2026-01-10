file='/data/pth/NETCDF/PRUDENCE/lsm.DMI.50km.nc'
ncdf_cat,file
ncid = NCDF_OPEN(file)            ; Open The NetCDF file

NCDF_VARGET, ncid,  'lat', lat      ; Read in variable 'lat'

NCDF_VARGET, ncid,  'lon', lon      ; Read in variable 'lon'

NCDF_VARGET, ncid,  'lsm', lsm      ; Read in variable 'lsm'        ; minus 1 is land and +1 is sea


NCDF_CLOSE, ncid 
;

contour,lsm,lon,lat

end
