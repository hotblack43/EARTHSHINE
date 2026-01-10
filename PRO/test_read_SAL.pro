; get the lat lon grid:
cdfid = ncdf_open( '/data/pth/CMSAF/CM_SAF_MA.nc')
ncdf_varget, cdfid, 'Longitude', lon
ncdf_varget, cdfid, 'Latitude', lat
ncdf_close, cdfid
;
cdfid = ncdf_open( 'testSAL.nc')
ncdf_varget, cdfid, 'Data', SAL
ncdf_close, cdfid
;
;device,decomposed=0
set_plot,'ps
loadct,19
device,/color
map_set,limit=[-80,-70,80,70]
contour,SAL,lon,lat,/cell_fill,/overplot,nlevels=31
map_continents,/overplot
end

