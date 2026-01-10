PRO Threedrotate,vx,vy,vz,x,y,z,xnew,ynew,znew
; given a description of a rotation axis (lat,long) and a rotation angle about that axis (a)
; this routine produces new Cartesian coordinates from old Cartesian coordinates
; All input angles in DEGREES
; Matrix for rotation about x axis
Rx=[[1.0d0,0.0d0,0.0d0],[0.0d0,cos(vx*!dtor),-sin(vx*!dtor)],[0.0d0,sin(vx*!dtor),cos(vx*!dtor)]]
; Matrix for rotation about y axis
Ry=[[cos(vy*!dtor),0.0d0,sin(vy*!dtor)],[0d0,1d0,0d0],[-sin(vy*!dtor),0.0d0,cos(vy*!dtor)]]
; Matrix for rotation about z axis
Rz=[[cos(vz*!dtor),-sin(vz*!dtor),0.0d0],[sin(vz*!dtor),cos(vz*!dtor),0.0d0],[0.0d0,0.0d0,1.0d0]]
; Matrix for x, then y, then z axis rotation
R=Rz##Ry##Rx
vector=[x,y,z]
prod=R##transpose(vector)
xnew=prod(0)
ynew=prod(1)
znew=prod(2)
return
end
