PRO rotforward,arr,para
lon=para(0)
rot=para(1)
lat=para(2)
l=size(arr,/dimensions)
fmt='(3(a,2(f9.4,1x)))'
print,'Testing the forward rotation:'
for ipos=0,l(1)-1,1 do begin
    RA1=arr(0,ipos)
    DEC1=arr(1,ipos)
    RA2=arr(2,ipos)
    DEC2=arr(3,ipos)
    coordstoDEGS,RA1,DEC1,plonE1,platE1
    lonlattoCart,plonE1,platE1,x1,y1,z1
; rotate the first position by the supposed solution
rotpoint,x1,y1,z1,'x',lon,x1,y1,z1,/DEG
rotpoint,x1,y1,z1,'y',rot,x1,y1,z1,/DEG
rotpoint,x1,y1,z1,'z',lat,xnew1,ynew1,znew1,/DEG
    carttolonlat,lon_new,lat_new,xnew1,ynew1,znew1
; and compare it to the second position
    coordstoDEGS,RA2,DEC2,plonE2,platE2
    print,format=fmt,'2-(1,rot): ',plonE2-lon_new,platE2-lat_new
endfor
stop
return
end
