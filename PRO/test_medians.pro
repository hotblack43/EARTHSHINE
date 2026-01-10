n=100
x=randomu(seed,n)
print,'Median: ',median(x)
print,'Mean  : ',mean(x)
idx=where(x gt 0.7)
xmed=median(x(idx))
x(idx)=(x(idx)-xmed)*3.+xmed
print,'Median: ',median(x)
print,'Mean  : ',mean(x)
end
