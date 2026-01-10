
PRO find_circle_inside_outside,radius,CENTER,inside,outside,l,idx_inside,idx_outside
inside=intarr(l)
outside=intarr(l)
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r2= (i-CENTER(0))^2+(j-CENTER(1))^2
		if (r2 gt radius^2) then outside(i,j)=1 ELSE inside(i,j)=1
	endfor
endfor
idx_inside=where(inside eq 1)
idx_outside=where(outside eq 1)
return
end
