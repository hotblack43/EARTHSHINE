for j=2.0,5,0.5 do begin
n=10^j
x=randomu(seed,1e5)*n
y=x*0.0
for i=0L,1e5-1,1 do begin
y(i)=randomu(seed,poisson=x(i))
endfor
yy=y
!P.MULTI=[0,1,1]
y=long(Y/float(n)*float(2L^16-1))
z=yy/float(n)*float(2L^16-1)
delta=(z-y)/z*100.0
!P.CHARSIZE=2
!P.CHARthick=2
!X.thick=2
!Y.thick=2
plot_oo,z,abs(delta),psym=7,yrange=[1e-12,100],ystyle=1,xrange=[1,1e5],xstyle=1,xtitle='Float scaled to 16 bits',ytitle='Error [%]',title='16 bits float, vs 16 bits integer'
xyouts,10,1e-7,'N = 10 ^'+string(j)
endfor
end
