npoints=100
x=findgen(npoints)-npoints/2.
a=randomn(seed)
b=randomn(seed)
c=randomn(seed)
print,a,b,c
y=a*x^3+b*x^2+c*x
idx=indgen(npoints-1)+1
jdx=indgen(npoints-1)
kdx=indgen(npoints-1)-1
mdx=where(y(idx) lt y(jdx) and y(jdx) gt y(kdx))
if (mdx(0) ne -1) then begin
	print,mdx,y(mdx+1),y(mdx),y(mdx-1)
	plot,x,y,xrange=[x(mdx)-5,x(mdx)+5],ystyle=1
	endif
end

