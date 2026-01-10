

line=[0,144,538,538]
point1=[00,200]
n=538
plane=fltarr(n,n)*0
for i=0,n-1,1 do begin
for j=0,n-1,1 do begin
point2=[i,j]
plane(i,j)=test_if_same_side(line,point1,point2)
endfor
endfor
surface,plane,charsize=2
end