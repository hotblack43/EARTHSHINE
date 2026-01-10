file='proxies.dat'
data=get_data(file)
time=reform(data(0,*))
proxy=reform(data(1:22,*))
file='Temp4Bo.dat'
data=get_data(file)
cali_time=reform(data(0,*))
cali_temp=reform(data(1,*))
ncalitemp=n_elements(cali_time)
cali_temp=cali_temp+randomn(seed,ncalitemp)*2.
idx=where(time ge cali_time(0) and time le cali_time(ncalitemp-1))
xx=proxy(*,idx)
yy=cali_temp
res1=regress(xx,yy,yfit=yfit,/double,const=const)
p=0.05
res2=backw_elim(xx,yy,p,varlist=vars,/double,yfit=BEyfit)
print,'R(yy,yfit|regress):',correlate(yy,yfit)
print,'R(yy,yfit|BE)     :',correlate(yy,BEyfit)
end
