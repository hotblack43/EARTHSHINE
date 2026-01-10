

PRO gfunct, X, A, F, pder
 bx=exp(-a(2)*x)
  F = a(0)+a(1)*bx
 
;If the procedure is called with four parameters, calculate the
;partial derivatives.
  IF N_PARAMS() GE 4 THEN $
    pder = [[replicate(1.0, N_ELEMENTS(X))], [bx], [-bx*x*a(1)]]
END




data=get_data('2456091_xy.dat')
x=reform(data(0,*))
idx=sort(x)
data=data(*,idx)
x=reform(data(0,*))
y=reform(data(1,*))
weights=x*0.0+1.0d0
nMC=10000L
for iMc=0,nMC-1,1 do begin
a=randomu(seed,3)*1.0d0
yfit=curvefit(x,y,weights,/double,a,sigma,itmax=1000,iter=iter,function_name='gfunct',status=status)
print,status
!P.charsize=2
!P.thick=3
!P.charthick=2
if (status eq 0) then begin
print,'Solve: ',a
if (iMC eq 0) then plot,x,y,psym=7,xstyle=3,ystyle=3
oplot,x,yfit,color=fsc_color('red')
rmse=sqrt(total(y-yfit)^2/n_elements(x))
print,'rmse: ',rmse
print,'n iter: ',iter
endif else begin
print,status,' is not good.'
endelse
endfor
end
