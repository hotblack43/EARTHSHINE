data=get_data('iloop_collection.txt')
jd=reform(data(0,*))
alfa=reform(data(1,*))
offset=reform(data(2,*))
albedo=reform(data(3,*))
DS=reform(data(4,*))
tot=reform(data(5,*))
err=reform(data(6,*))
print,'SD. albedo: ',stddev(albedo)/mean(albedo)*100.,' in % of mean albedo.'
print,'Mean error in % in box on lunar disc: ',mean(DS)
end
