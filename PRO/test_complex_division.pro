a=double(randomn(seed))
b=double(randomn(seed))
c=double(randomn(seed))
d=double(randomn(seed))
x=dcomplex(a,b)
y=dcomplex(c,d)
z=x/y
print,'x/y                             :',z
w=x*conj(y)/(y*conj(y))
print,'x*conj(y)/(y*conj(y))           :',w
u=(a*c+b*d+(b*c-a*d)*dcomplex(0,1))/(c*c+d*d)
print,'long way                        :',u
print,'difference                      :',w-z
print,'difference                      :',u-z
end

