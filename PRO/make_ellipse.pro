PRO make_ellipse,x0,y0,r1,r2,x,y
angle=findgen(3000)/3000.*360.0
x=fix(x0+r1*cos(angle*!dtor))
y=fix(y0+r2*sin(angle*!dtor))
return
end

