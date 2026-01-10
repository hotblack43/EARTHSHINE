nsim=50
n=8*650L


for isim=0,nsim-1,1 do begin
	x=randomu(seed,n)
	x=(x-min(x))
	x=x/max(x)*60000.0d0
	idx=sort(x)
	x=x(idx)
	w=long(x)
	error=(x-w)/x
	;plot_oo,x,error,charsize=2,title=string(isim),xrange=[1,n],yrange=[1e-7,1]
	if (isim eq 0) then sum=error
	if (isim gt 0) then sum=sum+error
endfor
	sum=sum/float(nsim)
	plot_oo,x,sum,charsize=2,title=string(isim),xrange=[1,1e6],yrange=[1e-7,1]
end

