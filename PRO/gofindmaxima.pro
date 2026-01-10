PRO gofindmaxima,x,y,xwhere
for i=1,n_elements(x)-2,1 do begin
if (y(i) gt y(i-1) and y(i) gt y(i+1)) then begin
	print,'Max phase at: ',x(i)
	xwhere=x(i)
endif
endfor	
return
end
