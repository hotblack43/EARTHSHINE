a=1.2
da=1.9
b=1.3
db=0.4
x=findgen(60)-20
offset=mean(x)
x=x-offset
y=a+b*x
x2=x(10:50)
y2=a+b*x2
dy=sqrt(da^2+(x*db)^2)
plot,x2+offset,y2,xrange=[min(x),max(x)+20],xstyle=1, $
yrange=[-50,70]
oplot,x+offset,y+dy,linestyle=3
oplot,x+offset,y-dy,linestyle=3
end