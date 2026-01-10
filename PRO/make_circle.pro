PRO make_circle,x0,y0,r,x,y
angle=findgen(6000)/6000.*360.0
idx=where(angle gt 30 and angle lt 150)
angle=angle(idx)
x=fix(x0+r*cos(angle*!dtor))
y=fix(y0+r*sin(angle*!dtor))
; make another layer
x=[x,fix(x0+(r+1)*cos(angle*!dtor))]
y=[y,fix(y0+(r+1)*sin(angle*!dtor))]
; make another layer
x=[x,fix(x0+(r-1)*cos(angle*!dtor))]
y=[y,fix(y0+(r-1)*sin(angle*!dtor))]
return
end

