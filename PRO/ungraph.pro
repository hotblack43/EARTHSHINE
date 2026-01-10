file='arnoldtablefig2.dat'
;
data=get_data(file)
x=reform(data(0,*))
y=reform(data(1,*))
x_offset=410.
y_offset=0.5
x_factor=(800.-410.)/(500.-52.)
y_factor=(2.0-0.5)/(412.-38.)
x_new=x_offset+x_factor*(x-52.)
y_new=y_offset+y_factor*(y-38.)
for i=0,n_elements(x)-1,1 do print,x(i),y(i),x_new(i),y_new(i)
openw,12,'new.data'
for i=0,n_elements(x)-1,1 do printf,12,x_new(i),y_new(i)
close,12
end

