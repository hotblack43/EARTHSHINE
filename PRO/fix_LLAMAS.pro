data=get_data('LLAMAS_Fig3_digitized.raw')
phase=reform(data(0,*))
logval=reform(data(1,*))
val=10^(logval)
plot_io,abs(phase),val
openw,33,'LLAMAS.dat'
for i=0,n_elements(val)-1,1 do begin
printf,33,phase(i),val(i)
endfor
close,33
end
