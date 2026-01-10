PRO get_exposure_factor,days,factor
file='moonbrightness.tab'
data=get_data(file)
d=reform(data(0,*))
f=reform(data(2,*))
factor=1./interpol(f,d,days)
return
end
