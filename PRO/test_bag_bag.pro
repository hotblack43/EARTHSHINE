
PRO gofit,x,y,nMC,meana0,a0SD,meanslope,slopeSD
n=n_elements(x)
listen=[]
for i=0,nMC-1,1 do begin
idx=fix(randomu(seed,n)*n)
res=linfit(x(idx),y(idx))
listen=[[listen],[res]]
endfor
meana0=mean(listen(0,*))
a0SD=stddev(listen(0,*))
meanslope=mean(listen(1,*))
slopeSD=stddev(listen(1,*))
return
end

n=100
x=findgen(n)
y=1.2*x
noise=randomn(seed,n)
y=y+noise
nMC=1000
gofit,x,y,nMC,meana0,a0SD,meanslope,slopeSD
;
n=n_elements(x)
listen=[]
for jMC=0,nMC-1,1 do begin
idx=fix(randomu(seed,n)*n)
gofit,x(idx),y(idx),nMC,meana0,a0SD,meanslope,slopeSD
listen=[[listen],[meana0,a0SD,meanslope,slopeSD]]
endfor
print,mean(listen(0,*)),stddev(listen(0,*)),mean(listen(2,*)),stddev(listen(2,*))
print,mean(listen(0,*)),mean(listen(1,*)),mean(listen(2,*)),mean(listen(3,*))
print,meana0,a0SD,meanslope,slopeSD
end
