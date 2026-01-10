FUNCTION SUNEARTHMOON_ANGLE,jd
; returns the angle between Moon-Earth-Sun - i.e. as seen from Earth
; the angular separation between Moon and Sun
mphase,jd,k
MOONPOS, jd, ramoon, decmoon, dis, geolong, geolat,/RADIAN
SUNPOS, jd, rasun, decsun, elong,oblt,/RADIAN
d = sphdist(geolong, geolat, elong, 0.0)/!pi*180.0d0
return,d
end
