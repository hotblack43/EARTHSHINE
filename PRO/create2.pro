file='hejsa.nc'
cdfid = ncdf_open( file )
ncdf_varget, cdfid, 'lon', lon
nlon=n_elements(lon)
ncdf_varget, cdfid, 'lat', lat
nlat=n_elements(lat)
ncdf_varget, cdfid, 'var129', gph0_1
ncdf_close, cdfid
h0=gph0_1/9.80665
; flip h0 her...
if_flip=1
if (if_flip eq 1) then h0=reverse(h0,1)
;
nlevels=9
levels=indgen(nlevels)*1000+1000
c_labels=indgen(nlevels)*0+1
map_set,title='gph0/9.80665 from file:'+file+', 1000m contours'
contour,h0,lon,lat,levels=levels,c_labels=c_labels,charsize=2,/cell_fill,/overplot
contour,h0,lon,lat,levels=levels,c_labels=c_labels,/overplot
map_continents,/overplot
; now write out the heights as a table for a FORTRAN DATA statement
OPENW, lun, 'NEWorography.bin', /GET_LUN, /F77_UNFORMATTED  
  
;Write the data.  
WRITEU, lun, nlon
WRITEU, lun, nlat
WRITEU, lun, lon
WRITEU, lun, lat
WRITEU, lun, h0
  
;Close the file.  
FREE_LUN, lun 
end
