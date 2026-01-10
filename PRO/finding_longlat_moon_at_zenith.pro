PRO finding_longlat_moon_at_zenith,mm,dd,yy,hr,min,sec,longitude,latitude
; will find the geographic longitude and latitude at which the Moon 
; is in zenith, given the time and date, the answer is probably not 
; accurate beyond about 1 degree.

mjd=julday(mm,dd,yy,hr,min,sec)-2400000.5d0
TAI=MJD*24.0d0*3600.0d0	; seconds since MJD 0
nlon=360
nlat=180+1
lon=fltarr(nlon,nlat)
lat=fltarr(nlon,nlat)
restore,'lonlat.bin'
zenithang=moon_zenith(TAI,lon=lon,lat=lat)
idx=where(zenithang eq min(zenithang))
longitude=lon(idx)
latitude=lat(idx)
return
end
