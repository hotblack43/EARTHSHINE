PRO lonlattocart,lon,lat,x,y,z
; calculate x,y,z on a R=1 sphere given lon and lat of the point
Result = CV_COORD(/DEGREES,/DOUBLE,FROM_SPHERE=[lon,lat,1.0d0],/TO_RECT)
x=Result(0)
y=Result(1)
z=Result(2)
;print,'Calc r:',sqrt(x^2+y^2+z^2)
return
end
