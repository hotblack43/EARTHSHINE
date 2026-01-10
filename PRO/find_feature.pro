PRO find_feature,orgimage,image,x0,y0,r,angle
tvscl,orgimage
print,'CLICK ON FEATURE!!'
cursor,a,b,/device
plots,[a,a],[b,b],psym=7,/device
plots,[x0,x0],[y0,y0],psym=6,/device
angle=atan((y0-b)/(x0-a))/!dtor
print,'Angle found was:',angle,' degrees',(y0-b)/(x0-a)
return
end

