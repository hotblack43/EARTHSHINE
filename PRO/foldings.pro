t=0.01
c=3.6
sum=0
for i=0,100,1 do begin
sum=sum+t*2^(i/c)
print,i,t*2^(i/c),sum
endfor
end
