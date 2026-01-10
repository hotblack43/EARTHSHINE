PRO lonlattoCart,lon,lat,x,y,z
; calculate x,y,z on a R=1 sphere given lon and lat of the point
; all angle sin DEGREES
x=cos(lat*!dtor)*cos(lon*!dtor)
y=cos(lat*!dtor)*sin(lon*!dtor)
z=sin(lat*!dtor)
return
end

PRO Threedrotate,lat,long,x,y,z,xnew,ynew,znew,a
; given a description of a rotation axis (lat,long) and a rotation angle about that axis (a)
; this routine produces new Cartesian coordinates from old Cartesian coordinates
; All input angles in DEGREES
     c1=cos(lat*!dtor)*cos(long*!dtor)
     c2=cos(lat*!dtor)*sin(long*!dtor)
     c3=sin(lat*!dtor)
xnew = x*cos(a*!dtor)+ (1.0d0 - cos(a*!dtor))*(c1*c1*x + c1*c2*y + c1*c3*z) + (c2*z - c3*y)*sin(a*!dtor)
ynew = y*cos(a*!dtor)+ (1.0d0 - cos(a*!dtor))*(c2*c1*x + c2*c2*y + c2*c3*z) + (c3*x - c1*z)*sin(a*!dtor)
znew = z*cos(a*!dtor)+ (1.0d0 - cos(a*!dtor))*(c3*c1*x + c3*c2*y + c3*c3*z) + (c1*y - c2*x)*sin(a*!dtor)
return
end

FUNCTION alignment,pars
long=pars(0) 
lat=pars(1) 
a=pars(2)
print,long,lat,a
;
;E1: 18:20:11.665, +03:17:26.152
;E2: 18:20:08.522, +03:17:49.439 
plonE1=ten(18.*15.d0,20.d0,11.665d0) & platE1=ten(03.d0,17.d0,26.152d0)
plonE2=ten(18.*15.d0,20.d0,08.522d0) & platE2=ten(03.d0,17.d0,49.439d0)
lonlattoCart,plonE1,platE1,x1,y1,z1
lonlattoCart,plonE2,platE2,x2,y2,z2
Threedrotate,lat,long,x1,y1,z1,xnew1,ynew1,znew1,a
d1=[x2,y2,z2]-[xnew1,ynew1,znew1]
e1=total(d1^2)
;S1: 13:54:10.407, -19:06:52.553
;S2: 13:54:09.741, -19:06:43.784 
plonS1=ten(13.*15.,54,10.407) & platS1=ten(-19,06,52.553)
plonS2=ten(13.*15.,54,09.741) & platS2=ten(-19,06,43.784)
lonlattoCart,plonS1,platS1,x1,y1,z1
lonlattoCart,plonS2,platS2,x2,y2,z2
Threedrotate,lat,long,x1,y1,z1,xnew1,ynew1,znew1,a
d2=[x2,y2,z2]-[xnew1,ynew1,znew1]
e2=total(d2^2)
;W1: 09:13:41.508, -10:49:04.877
;W2: 09:13:39.970, -10:49:08.317
plonW1=ten(09.*15.,13,41.508) & platW1=ten(-10,49,04.877)
plonW2=ten(09.*15.,13,39.970) & platW2=ten(-10,49,08.317)
lonlattoCart,plonW1,platW1,x1,y1,z1
lonlattoCart,plonW2,platW2,x2,y2,z2
Threedrotate,lat,long,x1,y1,z1,xnew1,ynew1,znew1,a
d3=[x2,y2,z2]-[xnew1,ynew1,znew1]
e3=total(d3^2)
;print,'total err:',e1+e2+e3
;print,d1
;print,d2
;print,d3
return,e1+e2+e3
end

start_params=randomu(seed,3)
xi = TRANSPOSE([[1.0, 0.0, 0.0],[0.0, 1.0, 0.0],[0.0, 0.0, 1.0]])
ftol=1.0d-8
POWELL, start_params, xi, ftol, fmin, 'alignment',/DOUBLE
print,'xi:',xi
print,'Solution: ',start_params
print,'Rot axis longitude=',start_params(0),' Degrees'
print,'Rot axis latitude=',start_params(1),' Degrees'
print,'Rotation angle =',start_params(2),' Degrees',start_params(2)*3600.,' arc secs.'
end
