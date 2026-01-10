PRO carttolonlat,lon,lat,x,y,z
; converts Cartesian x,y,z to longitude,latitude
Result = CV_COORD(FROM_RECT=[x,y,z], /DEGREES, /DOUBLE, /TO_SPHERE)
lon=Result(0)*1.0d0
lat=Result(1)*1.0d0
radius=Result(2)*1.0d0
if (lon lt 0) then lon=360.0d0+lon
return
end
