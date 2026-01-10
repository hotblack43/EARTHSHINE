

FUNCTION gettheflux,n10
m=10-2.5*alog10(n10)
mprime=m+2.5*alog10(3600.)
m2prime=mprime-2.5*alog10(6.67^2)
cps=10^((15.1-m2prime)/2.5)
return,cps
end


; code to calculate uncertainty in counts for ZL given changes in the ZL tables in units of S10.

n10_1=347
n10_2=395
f1=gettheflux(n10_1)
f2=gettheflux(n10_2)
print,'Ratio of flux 1 to 2 : ',f1/f2
end
