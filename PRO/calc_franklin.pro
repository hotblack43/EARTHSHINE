data=get_data('FA_FRANKLIN_BV.data')
v=reform(data(0,*))
b=reform(data(1,*))
print,'mean B minus mean V : ',mean(B)-mean(V)
print,'mean (B-V): ',mean(B-v)
end
