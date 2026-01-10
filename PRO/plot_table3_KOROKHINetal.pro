FUNCTION formula4,m1,m2,rho,alfa
res=m1*exp(-rho*alfa)+m2*exp(-0.7*alfa)
return,res
end

file='table3_KOROKHINetal.dat'
data=get_data(file)
lamda=reform(data(0,*))
m1=reform(data(1,*))
rho=reform(data(2,*))
m2=reform(data(3,*))
sigma=reform(data(4,*))
icount=0
for alfa=0.1,89,.1 do begin
alb_U=formula4(m1(0),m2(0),rho(0),alfa)
alb_B=formula4(m1(1),m2(1),rho(1),alfa)
alb_V=formula4(m1(2),m2(2),rho(2),alfa)
alb_I=formula4(m1(3),m2(3),rho(3),alfa)
UminusB=alb_B-alb_U
UminusV=alb_V-alb_U
UminusI=alb_I-alb_U
BminusV=alb_V-alb_B
if (icount eq 0) then begin
x=alfa
y1=UminusB
y2=UminusV
y3=BminusV
y4=UminusI
endif
if (icount gt 0) then begin
x=[x,alfa]
y1=[y1,UminusB]
y2=[y2,UminusV]
y3=[y3,BminusV]
y4=[y4,UminusI]
endif
icount=icount+1
endfor
!P.MULTI=[0,1,2]
plot_oo,x,y1,xtitle='Phase angle',ytitle='!7D!3 albedo',charsize=2,$
title='361 nm to 859 nm (thick line)'
oplot,x,y2,linestyle=4
oplot,x,y3,linestyle=3
oplot,x,y4,thick=2
plot_io,x,y1,xtitle='Phase angle',ytitle='!7D!3 albedo',charsize=2, $
xrange=[0,10],xstyle=1
oplot,x,y2,linestyle=4
oplot,x,y3,linestyle=3
oplot,x,y4,thick=2
end

