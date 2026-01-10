PRO annotate,hr,mi,se,txt
x=julday(7,15,2009,hr,mi,se)-julday(7,15,2009)
plots,[x,x],[200,350],color=fsc_color('red') & xyouts,x,360,txt,orientation=90
return
end

file='logged.txt'
data=get_data(file)
mm=reform(data(0,*))
dd=reform(data(1,*))
yy=reform(data(2,*))
hr=reform(data(3,*))
mi=reform(data(4,*))
se=reform(data(5,*))
dt=reform(data(6,*))
;
jd=double(julday(mm,dd,yy,hr,mi,se))-julday(7,15,2009)
plot,jd,dt,xtitle='Day',ytitle='Peltier reading (arb. units)',xrange=[0.5,1.0]
annotate,16,39,00,'On l co'
annotate,16,46,00,'Off l co'
annotate,16,59,00,'On u co'
annotate,17,06,00,'Off u co'
annotate,17,28,00,'Cooling'
annotate,25,00,00,'1 AM'
annotate,26,00,00,'2 AM'
annotate,27,00,00,'3 AM'
annotate,27,59,00,'Sunrise'
annotate,29,00,00,'5 AM'
annotate,30,00,00,'6 AM'
annotate,31,00,00,'7 AM'
annotate,32,00,00,'8 AM'
annotate,33,00,00,'9 AM'
annotate,34,00,00,'10 AM'
end