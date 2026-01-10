angle=findgen(2000)/2000.*2.*!pi

radius=3
x=radius*cos(angle)
y=radius*sin(angle)
plot,x,y,/isotropic,xrange=[-6,6],yrange=[-6,6],thick=3

radius=5.5
idx=(where(angle gt 30.*!dtor and angle lt 50.*!dtor))
x=radius*cos(angle(idx))
y=radius*sin(angle(idx))
oplot,x,y

radius=5
idx=(where(angle gt 32.*!dtor and angle lt 48.*!dtor))
x=radius*cos(angle(idx))
y=radius*sin(angle(idx))
oplot,x,y

radius=4.5
idx=(where(angle gt 30.*!dtor and angle lt 47.*!dtor))
x=radius*cos(angle(idx))
y=radius*sin(angle(idx))
oplot,x,y


; draw radii
x=indgen(2000)/2000.*12
y=0.7*x
oplot,x,y
x=indgen(2000)/2000.*12
y=0.9*x
oplot,x,y
xyouts,/data,0,3.3,'Area 1'
xyouts,/data,2,5.3,'Area 2'
arrow,/data,2.5,3.5,3.8,3.0,thick=2
arrow,/data,5.0,5.5,4.1,3.2,thick=2
end