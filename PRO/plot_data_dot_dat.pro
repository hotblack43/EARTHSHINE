;------------- plot it
data=get_data('data.dat')
p1=reform(data(1,*))
p2=reform(data(2,*))
rat=reform(data(3,*))
p3=reform(data(4,*))
p4=reform(data(5,*))
rat2=reform(data(6,*))
days=indgen(n_elements(p1))
!P.MULTI=[0,1,1]
plot_io,days/24./4.,rat,ytitle='Grimaldi/Crisium ratio',charsize=2,psym=-3,xstyle=1,xtitle='Days',xrange=[13.5,22]
oplot,days/24./4.,rat2,psym=7,linestyle=2
plot_io,days/24./4.,rat,ytitle='Grimaldi/Crisium ratio',charsize=2,psym=-3,xstyle=1,xtitle='Days'
oplot,days/24./4.,rat2,psym=7,linestyle=2
end
