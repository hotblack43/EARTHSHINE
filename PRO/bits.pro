FUNCTION laptrsf_onevalue,z_or_svalue,f,x_or_t
; Performs a forward Laplace transform for one value of z
y=f*exp(-x_or_t*z_or_svalue)
realpart=int_tabulated(x_or_t,double(y),/double)
imagpart=int_tabulated(x_or_t,imaginary(y),/double)
onevalue=complex(realpart,imagpart)
return,onevalue
end

FUNCTION forwLaplace,f,x_or_t,z_or_s
n=n_elements(z_or_s)
laptrsf=dcomplexarr(n)
for i=0,n-1,1 do begin
        laptrsf(i)=laptrsf_onevalue(z_or_s(i),f,x_or_t)
endfor
return,laptrsf
end

Nt=100
x_or_t=findgen(Nt)
z_or_s=complex(0,1)*1./(1.0+dindgen(Nt))
f=exp(-findgen(Nt))
f=findgen(Nt)*0.0+1.0
res=forwLaplace(f,x_or_t,z_or_s)
plot,res
oplot,1./z_or_s
end
