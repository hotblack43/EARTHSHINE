FUNCTION findGDdistance,alt1,az1,alt2,az2
; finds the great circle distance in degrees between the two points
; all inputs are in degrees
GC=great_circle(az1,alt1,az2,alt2)/6378388.d0/!pi/2.*360.0
return,GC
end
