file='no_header_test.cat'
data=get_data(file)
x=reform(data(1,*))
y=reform(data(2,*))
flags=reform(data(8,*))
idx=where((flags eq 0) and (x gt 10 and x le 511-10) and (y gt 10 and y le 511-10))
data=data(*,idx)
num=reform(data(0,*))
x=reform(data(1,*))
y=reform(data(2,*))
xf=reform(data(3,*))
yf=reform(data(4,*))
flux=reform(data(5,*))
mag=reform(data(6,*))
radii=reform(data(7,*))
;
histo,mag,min(mag),max(mag),0.2
;
jdx=where(mag gt min(mag)+6)
print,flux(jdx)
end

