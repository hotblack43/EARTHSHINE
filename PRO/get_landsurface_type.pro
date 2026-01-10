PRO get_landsurface_type,IGBP,lon,lat
f='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/AUXILLIARY/CERES_IGBP_LandCover_1x1.nc'
id = NCDF_OPEN(f)
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'IGBP',   IGBP 
NCDF_CLOSE,  id
return
end
