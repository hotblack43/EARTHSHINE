; calculate focal length
w=6	; width of sensor or image on sensor, in mm
fov=2.5	; field of view in degrees
f=1./(tan(!dtor*fov/2.)/w*2.)	; focal length in mm
print,f
fov_check=2.*atan(w,2.*f)
print,fov_check/!dtor
end