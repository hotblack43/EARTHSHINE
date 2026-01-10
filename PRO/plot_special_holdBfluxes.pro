data=get_data('holdBfluxes.dat')
tot=reform(data(0,*))
expt=reform(data(1,*))
am=reform(data(2,*))
ph=reform(data(3,*))
minval=reform(data(4,*))
geofac=reform(data(5,*))
type=reform(data(6,*))
jd=reform(data(7,*))
;select
offset=0.010
flux=tot/(expt-offset)
idx=where(jd gt 2456027.0d0 and jd lt 2456028.999)
plot,am(idx),flux(idx),psym=7
end
