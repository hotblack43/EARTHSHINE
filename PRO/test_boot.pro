FUNCTION bootstd,x
nboot=100
val=fltarr(nboot)
m=n_elements(x)
for i=0,nboot-1,1 do begin
idx=fix(randomu(seed,m)*m)
val(i)=mean(x(idx))
endfor
stdmean=stddev(val)
std=stdmean*sqrt(nboot-1.)
return,std
end

PRO bootestimator,x,stdboot
l=n_elements(x)
nboot=1000
val=fltarr(nboot)
for i=0,nboot-1,1 do begin
idx=fix(randomu(seed,l)*l)
val(i)=mean(x(idx))
endfor
stdboot=stddev(val)
return
end

n=1000
mits=100
for i=0,mits-1,1 do begin
x=randomn(seed,n)
bootestimator,x,stdboot
stdboot2=bootstd(x)
print,i,stddev(x)/sqrt(n-1),stdboot,stdboot2
endfor
end
