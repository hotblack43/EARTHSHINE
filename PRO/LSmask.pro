PRO get_Earth_albedo,albedo,lon,lat
; First reads a funny LS mask - with continental shelves marked as land
; Her emodified to have polar caps (+/- 80 degrees) masked to 0.95
; all oceans to 0.1, and all land to 0.6
file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\mash_025d_v10a.nc'
ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'long',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'mask_shelf',   lsm
NCDF_CLOSE,  id
oceanalbedo=0.1
landalbedo=0.6
; mask all oceans to 0.1
idx=where(lsm eq 1)
lsm(idx)=oceanalbedo
; mask all land areas to 0.6
idx=where(lsm eq 0)
lsm(idx)=landalbedo

; Then reads a global cloud picture and scales it to fit above the LS mask
read_jpeg,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\clouds_2048.jpg',clouds
l_lsm=size(lsm,/dimensions)
l_clouds=size(clouds,/dimensions)
clouds=congrid(clouds,l_lsm(0),l_lsm(1))
albedo=0.8*(bytscl(bytscl(clouds)+bytscl(lsm))/256.)
;Poles all white
idx=where(lat gt 80 or lat lt -80)
albedo(*,idx)=0.95
return
end

get_Earth_albedo,albedo,lon,lat
print,mean( albedo )
;device,decomposed=0
loadct,0
map_set,15,70,0,/satellite,sat_p=[384000./6371.,0,0],/isotropic
device,decomposed=0
loadct,19
;
new=congrid(albedo,360,180)
new_lon=congrid(lon,360)
new_lat=congrid(lat,180)
contour,new,/cell_fill,new_lon,new_lat,nlevels=31,/overplot
openw,11,'earth.alb'
l=size(mew,/dimensions)
for  ilat=0,180-1,1 do begin
printf,11,format='(360(1x,f8.4))',new(*,ilat)
endfor
close,11
end