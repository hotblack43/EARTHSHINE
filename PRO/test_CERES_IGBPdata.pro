f='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/AUXILLIARY/CERES_SurfaceAlbedo.nc'
id = NCDF_OPEN(f)
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'albedo',    albedo
NCDF_CLOSE,  id
map_set,/isotropic,title='CERES Surface Albedo'
contour,albedo,lon,lat,/cell_fill,nlevels=101,/overplot
map_continents,/overplot

f='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/AUXILLIARY/CERES_IGBP_LandCover.nc'
id = NCDF_OPEN(f)
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'IGBP',   IGBP 
NCDF_CLOSE,  id
map_set,/isotropic,title='IGBP surface land type'
contour,IGBP,lon,lat,/cell_fill,nlevels=17,/overplot
map_continents,/overplot
end
