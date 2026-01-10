 PRO getcoordsfromheader,header,x0,y0,radius1,radius2,discra
 ; get X0
 idx=strpos(header,'DISCX0')
 jdx=where(idx ne -1)
 if (jdx(0) eq -1) then stop
 X0=float(strmid(header(jdx),10,19))
 ; get Y0
 idx=strpos(header,'DISCY0')
 jdx=where(idx ne -1)
 if (jdx(0) eq -1) then stop
 Y0=float(strmid(header(jdx),10,19))
 ; get DISCRA
 idx=strpos(header,'DISCRA')
 jdx=where(idx ne -1)
 if (jdx(0) eq -1) then stop
 discra=float(strmid(header(jdx),10,19))
 ; get RADIUS1
 idx=strpos(header,'Radius estimated from JD')
 jdx=where(idx ne -1)
 if (jdx(0) eq -1) then stop
 radius1=float(strmid(header(jdx),10,19))
 ; get RADIUS2
 idx=strpos(header,'Radius estimated from model image')
 jdx=where(idx ne -1)
 if (jdx(0) eq -1) then stop
 radius2=float(strmid(header(jdx),10,19))
;
x0=x0(0)
y0=y0(0)
radius1=radius1(0)
radius2=radius2(0)
discra=discra(0)
 return
 end



; will extract stats on the radius-discra quantity from a set of  'cubes' 
files=file_search('/data/pth/CUBES/cube_MkII_*',count=n)
openw,2,'delta_radii.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),header,/sil)
getcoordsfromheader,header,x0,y0,radiusJD,radiusMODIM,discra
print,discra-radiusJD,discra-radiusMODIM,radiusJD-radiusMODIM
printf,2,discra-radiusJD,discra-radiusMODIM,radiusJD-radiusMODIM

endfor
close,2
end
