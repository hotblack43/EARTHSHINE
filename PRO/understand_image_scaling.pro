n=1*65000L
x=randomu(seed,n)*n
x=x/max(x)*65000.0d0
x=x(sort(x))
z=long(x)
error=(x-z)/x
plot_oo,x,error,xstyle=1,ystyle=1,xrange=[1,max(x)],charsize=3,ytitle='Relative error',title='Rounding floats to max 65000 integer',yrange=[1e-7,1],xtitle='Float',psym=3
end

