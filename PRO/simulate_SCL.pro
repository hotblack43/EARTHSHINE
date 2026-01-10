m=5000
t=indgen(m)*10L+1900L
delta=randomn(seed,m)
epochs=t+delta
epochs=epochs(sort(epochs))
lengths=epochs-shift(epochs,1)
lengths=lengths(1:m-1)
n=n_elements(lengths)
print,'Mean length:',mean(lengths)
print,'STD length:',stddev(lengths)
scl=fltarr(n)*0.0+9999
for i=1,n-3,1 do begin
	l1=lengths(i-1)
	l2=lengths(i)
	l3=lengths(i+1)
	SCL(i)=(l1*1.0+l2*2.0+l3*1.0)/(1.+2.+1.)
endfor
idx=where(SCL ne 9999)
SCL=SCL(idx)
print,'Mean SCL121:',mean(SCL)
print,'STD SCL121:',stddev(SCL)
print,'SCL STD as % of STD lengths:',stddev(SCL)/stddev(lengths)*100.0
print,'SCL STD as % of STD epochs:',stddev(SCL)/stddev(delta)*100.0
end
