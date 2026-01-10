

nims=100
m=128*4
new=fltarr(m,m)
im=fltarr(m,m)*0+100.0
jm=randomu(seed,m,m,poisson=100)
for i=0,m-1,1 do begin
for j=0,m-1,1 do begin
new(i,j)=randomu(seed,poisson=nims*im(i,j))/nims
endfor
endfor
print,mean(jm),stddev(jm)^2
print,mean(new),stddev(new)^2
print,'Ratio of SD: ',stddev(jm)/stddev(new)

end
