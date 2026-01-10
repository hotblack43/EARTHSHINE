x0=1.3
xn=800
n=15
logrange=(alog10(xn)-alog10(x0))/float(n-1)
openw,1,'matchpoints.txt'
print,1.0
printf,1,1.0
for i=0,n-1,1 do begin
print,i,x0+10^(logrange*i)-1.0
printf,1,x0+10^(logrange*i)-1.0
endfor
close,1
end
