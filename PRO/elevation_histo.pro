file='elev.1-deg.nc'
ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'time',   time
NCDF_VARGET, id, 'data',   elev
elev=float(elev)/1000.
NCDF_CLOSE,  id
print,'Done!'
;
min=0
max=13
binsize=0.125
nbins=(max-min)/binsize
xarray=findgen(nbins)*binsize+min
h=histogram(elev(where(elev ge 0)),min=min,max=max,binsize=binsize)
plot_oi,xarray,h,psym=10,xtitle='elevation (km)',ytitle='N',title=str,charsize=1.5,xrange=[0.1,max(elev)]
end
