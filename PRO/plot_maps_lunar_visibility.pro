PRO  make_2d_density,selected_lon,selected_lat,surface,lonarr,latarr
latdel=5.
londel=5.
nlat=180./latdel
nlon=360./londel
lonarr=findgen(nlon)*londel
latarr=findgen(nlat)*latdel-90.
surface=intarr(nlon,nlat)
for lat=-90,90-latdel,latdel do begin
	for lon=0,360-londel,londel do begin
		idx=where(selected_lon gt lon and selected_lon le selected_lon+londel and(selected_lat gt lat and selected_lat le lat+latdel))
		if (idx(0) eq -1) then count=0
		if (idx(0) ne -1) then count=n_elements(idx)
		ilat=(lat+90)/latdel
		ilon=(lon- 0)/londel
		surface(ilon,ilat)=count
	endfor
endfor
return
end

DEVICE,DECOMPOSED=0
LOADCT,39

latdel=5.
londel=5.
nlat=180./latdel
nlon=360./londel
lonarr=findgen(nlon)*londel
latarr=findgen(nlat)*latdel-90.
file='data.dat'
data=get_data(file)
lat=reform(data(0,*))
lon=reform(data(1,*))
airmass=reform(data(2,*))
doy=reform(data(3,*))
;==================================
; make a map for a given time
uniq_days=doy(sort(doy))
uniq_days=uniq_days(uniq(uniq_days))
n_uniq_days=n_elements(uniq_days)
for iday=0,n_uniq_days-1,1 do begin
	idx=where(abs(doy - uniq_days(iday)) lt .20001)
	selected_lon=lon(idx)
	selected_lat=lat(idx)
	res=hist_2d(selected_lon,selected_lat,bin1=londel,bin2=latdel,min1=0,max1=360-londel,min2=-90,max2=90-latdel)
	;surface,res,/LEGO,charsize=2
		map_set
		contour,res,lonarr,latarr,/overplot,levels=indgen(21)
		map_continents,/overplot
endfor
end
