PRO rot3d,a,az,phi,x,y,z,xnew,ynew,znew
;print,a,az,phi,x,y,z
; a is the angle or rotation about the rotation axis
; az and phi are the azimuth and altitude of the rotation axis
; all angles in DEGREES
; x,y,z, coordinates of point to be rotated
    c1=cos(az*!dtor)*sin(phi*!dtor)
    c2=sin(az*!dtor)*sin(phi*!dtor)
    c3=cos(phi*!dtor)
xnew=x*cos(a*!dtor)+(1.0d0-cos(a*!dtor))*(c1*c1*x*!dtor+c1*c2*y*!dtor+c1*c3*z*!dtor)+(c2*z*!dtor-c3*y*!dtor)*sin(a*!dtor)
ynew=y*cos(a*!dtor)+(1.0d0-cos(a*!dtor))*(c2*c1*x*!dtor+c2*c2*y*!dtor+c2*c3*z*!dtor)+(c3*x*!dtor-c1*z*!dtor)*sin(a*!dtor)
znew=z*cos(a*!dtor)+(1.0d0-cos(a*!dtor))*(c3*c1*x*!dtor+c3*c2*y*!dtor+c3*c3*z*!dtor)+(c1*y*!dtor-c2*x*!dtor)*sin(a*!dtor)
return
end
