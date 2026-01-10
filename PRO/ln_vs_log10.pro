for x=3.0,9.0,1.0/6.0 do begin
z1=10.0^x
v1=z1-exp(alog(z1))
v2=z1-10.0^(alog10(z1))
print,format='(3(1x,g20.10))',x,v1/z1,v2/z1
endfor
end
