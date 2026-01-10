a=0.01
n=1000
x=indgen(n)-n/2.
y=exp(-abs(a*x))
plot,x,y
end
