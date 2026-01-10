PRO finding_longlat_moon_at_zenith,mm,dd,yy,hr,min,sec,longitude,latitude
; will find the geographic longitude and latitude at which the Moon 
; is in zenith, given the time and date, the answer is probably not 
; accurate beyond about 1 degree.

mjd=julday(mm,dd,yy,hr,min,sec)-2400000.5d0
TAI=MJD*24.0d0*3600.0d0	; seconds since MJD 0
; set up for half-degree precision
nlon=360*2.
nlat=180*2.+1
lon=fltarr(nlon,nlat)
lat=fltarr(nlon,nlat)
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
lon(ilon,ilat)=ilon
lat(ilon,ilat)=ilat-90
print,ilon,ilat,lon(ilon,ilat),lat(ilon,ilat)
endfor
endfor
save,lon,lat,filename='lonlat_half.bin'
zenithang=moon_zenith(TAI,lon=lon,lat=lat)
idx=where(zenithang eq min(zenithang))
;print,'Zenith angle is:',zenithang(idx),' at lon,lat=',lon(idx),lat(idx)
;!P.MULTI=[0,1,2]
;surface,zenithang,lon,lat,charsize=2
;contour,zenithang,lon,lat,charsize=2,/cell_fill,nlevels=100
longitude=lon(idx)
latitude=lat(idx)
return
end
mm=10
dd=26
yy=2011
hr=14
min=20
sec=20
finding_longlat_moon_at_zenith,mm,dd,yy,hr,min,sec,longitude,latitude
end
