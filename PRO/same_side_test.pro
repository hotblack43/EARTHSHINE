FUNCTION test_if_same_side,line,point1,point2
; Will test if two points are on the same side of a line
; INPUTS:
; line = [a1,a2,b1,b2], coords of two points ON the line
; point1 = [c1,c2], coords of the first point
; point2 = [d1,d2], coords of the second point
a1=double(line(0))
a2=double(line(1))
b1=double(line(2))
b2=double(line(3) )
c1=double(point1(0))
c2=double(point1(1))
d1=double(point2(0))
d2=double(point2(1))
stat1=crossp([a1-c1,a2-c2,0],[a1-b1,a2-b2,0])
stat2=crossp([a1-d1,a2-d2,0],[a1-b1,a2-b2,0])
test=(stat1(2)/abs(stat1(2)) eq stat2(2)/abs(stat2(2)))
;print,stat1,stat2
return,test
end

line=[0,144,538,538]
point1=[100,100]
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