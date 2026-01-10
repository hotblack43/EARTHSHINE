data=get_data('fluxes_temp.dat')
alfa=reform(data(0,*))
SSA=reform(data(1,*))
orig=reform(data(2,*))
after=reform(data(3,*))
pct=(after-orig)/orig*100.
plot,pct,orig,psym=3
end
