file='moonalbedo.dat'
albedo=intarr(1080,540)
openr,1,file
readf,1,albedo
close,1
l=size(albedo,/dimensions)
albedo=bytscl(congrid(albedo,l(0)/1,l(1)/1))
;albedo=reverse(albedo,1)

latmin = -90
latmax = 90

; Left edge is 0 East:
lonmin = 0

; Right edge is  +360:
lonmax =  360
polat=-6.8
for polat=90,-90,-10 do begin
polon=-5.6
rot=15.4
sat_dist=384000./1750.
MAP_SET, polat,polon,rot, /satellite, /ISOTROPIC, $
   LIMIT=[latmin, lonmin, latmax, lonmax] ,sat_p=[sat_dist,0,0],charsize=0.8
result = MAP_IMAGE(albedo,Startx,Starty, COMPRESS=1, $
   LATMIN=latmin, LONMIN=lonmin, $
   LATMAX=latmax, LONMAX=lonmax)

tv,result,startx,starty
wait,0.1

MAP_GRID, latdel=30, londel=30, /LABEL, /HORIZON
endfor
end