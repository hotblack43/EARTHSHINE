PRO geterr,RAstr1,DECstr1,lon_in,rot_in,lat_in,RAstr2,DECstr2,error
lon=lon_in & lat=lat_in & rot=rot_in
;....................................................
; convert positions from string to degrees
coordstoDEGS,RAstr1,DECstr1,plonE1,platE1
; convert the first lon,lat to Cartesian x,y,z
lonlattoCart,plonE1,platE1,x1,y1,z1
;....................................................
; convert positions from string to degrees
coordstoDEGS,RAstr2,DECstr2,plonE2,platE2
; convert the second lon,lat to Cartesian x,y,z
lonlattoCart,plonE2,platE2,x2,y2,z2
;....................................................
; rotate the first points
;Threedrotate,lon,rot,lat,x1,y1,z1,xnew1,ynew1,znew1
;rot3d,rot,lon,lat,x1,y1,z1,xnew1,ynew1,znew1
rotpoint,x1,y1,z1,'x',lon,x1,y1,z1,/DEG
rotpoint,x1,y1,z1,'y',rot,x1,y1,z1,/DEG
rotpoint,x1,y1,z1,'z',lat,xnew1,ynew1,znew1,/DEG
;....................................................
; find the distance between the rotated first position and the second point
distance=[x2,y2,z2]-[xnew1,ynew1,znew1]
error=total(distance^2)
;....................................................
return
end
