FUNCTION maskoutsky,X_in
x=x_in
l=size(x,/dimensions)
n=l(0)
maskoutskyk=x*0.0
rr=dblarr(n,n)
; get settings for maskoutsky
; define centre and radius of Moon in pixel coords
x0=282.5
y0=250.5
radius=223.5
if (file_test('lunarRim.dat') eq 1) then begin
openr,3,'lunarRim.dat'
readf,3,x0
readf,3,y0
readf,3,radius
close,3
endif
 for i=0,n-1,1 do begin
     for j=0,n-1,1 do begin
         rr(i,j)=sqrt((i-x0)^2+(j-y0)^2)
         endfor
     endfor
; setup the the sky maskoutsky
kdx=where(rr le radius)
maskoutskyk(kdx)=1
; apply maskoutsky
x=x*maskoutskyk
;surface,maskoutskyk
return,x
end
