FUNCTION xlog2x,x
common holder,iflag,data
if (iflag ne 314) then begin
file='xlog2x.dat'
data=get_data(file)
iflag=314
endif
answer=INTERPOL(data(1,*),data(0,*),x)
return,answer
end

common holder,iflag,data
iflag=0
for x=0.0,1.0,0.001 do begin
print,x,(xlog2x(x)-x*log2(x))/(x*log2(x))*100.0
endfor
end
