data=get_data('albedos6nights_twiomethods.dat')
a1=reform(data(0,*))
a2=reform(data(1,*))
da=a1-a2
histo,da,-.05,.05,0.0001
print,mean(da)
print,stddev(da)
end
