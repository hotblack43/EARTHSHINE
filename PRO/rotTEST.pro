vx=10	; degrees
vy=20	; degrees
vz=30	; degrees (remember 1 degree is 4 minutes)
n=100
for i=0,n-1,1 do begin
lon_in=randomu(seed)*360.d0
lat=randomu(seed)*180.d0-90.d0
lonlattocart,lon_in,lat,x,y,z
carttolonlat,lon1,lat1,x,y,z
;Threedrotate,vx,vy,vz,x,y,z,xnew,ynew,znew
rotpoint,x,y,z,'x',vx,x,y,z,/DEG
rotpoint,x,y,z,'y',vy,x,y,z,/DEG
rotpoint,x,y,z,'z',vz,xnew,ynew,znew,/DEG
CarttoLonLat,lon2,lat2,xnew,ynew,znew
;print,[x,y,z]-[xnew,ynew,znew]
radec, lon1, lat1, ihr1, imin1, xsec1, ideg1, imn1, xsc1
radec, lon2, lat2, ihr2, imin2, xsec2, ideg2, imn2, xsc2
if (lon2-lon1 gt 0) then begin
;print,'delta lon:',lon2-lon1
if (lat1 gt 0 and lat2 gt 0) then begin
if (ideg1 le 9) then ideg1str='+0'+string(ideg1)
if (ideg1 gt 9) then ideg1str='+'+string(ideg1)
if (ideg2 le 9) then ideg2str='+0'+string(ideg2)
if (ideg2 gt 9) then ideg2str='+'+string(ideg2)
ideg1str=strcompress(ideg1str,/remove_all)
ideg2str=strcompress(ideg2str,/remove_all)
print,format='(2(i2,a,i2,a,f6.3,1x,a3,a,i2,a,f6.3,1x,1x))',ihr1,':', imin1,':', xsec1,ideg1str,':', imn1,':', xsc1,ihr2,':', imin2,':', xsec2,ideg2str,':', imn2,':', xsc2
endif
endif
endfor
end
