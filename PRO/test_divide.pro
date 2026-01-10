n=3
a=complex(randomn(seed,n,n),randomn(seed,n,n))
b=complex(randomn(seed,n,n),randomn(seed,n,n))
inv_b=1./a
c=a*inv_b

for i=0,n-1,1 do begin
for j=0,n-1,1 do begin
print,c(i,j)
endfor
endfor
end

