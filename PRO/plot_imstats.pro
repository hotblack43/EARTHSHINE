!P.MULTI=[0,1,3]
!P.CHARSIZE=2
!X.style=1
data=get_data('imstats.dat')
jd=reform(data(0,*))
t=reform(data(1,*))
mn1=reform(data(2,*))
mn2=reform(data(3,*))
histo,mn1,min(mn1),max(mn1),(max(mn1)-min(mn1))/20.
histo,mn2,min(mn2),max(mn2),(max(mn2)-min(mn2))/20.
histo,t,min(t),max(t),(max(t)-min(t))/20.
print,'SD mn1:',stddev(mn1)/mean(mn1)*100.0
print,'SD mn2:',stddev(mn2)/mean(mn2)*100.0
print,'SD t  :',stddev(t)/mean(t)*100.0
end
