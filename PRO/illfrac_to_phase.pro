angle=findgen(360)-180
for i=0,359,1 do begin
k=0.5*(1+cos(angle(i)*!dtor))
print,angle(i),k
endfor
end

