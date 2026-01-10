FUNCTION extinction, X, A  
   extinct = a(0)*x^a(1)+a(2)*x^a(3)
   RETURN,[ extinct,x^a(1),a(0)*x^a(1)*alog(x),x^a(3),a(2)*x^a(3)*alog(x)]  
END  

PRO extract_data,data,date,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr
date=reform(data(0,*))
hjd=reform(data(1,*))
ku=reform(data(2,*))
kuerr=reform(data(3,*))
kb1=reform(data(4,*))
kb1err=reform(data(5,*))
kb=reform(data(6,*))
kberr=reform(data(7,*))
kb2=reform(data(8,*))
kb2err=reform(data(9,*))
kv1=reform(data(10,*))
kv1err=reform(data(11,*))
kv=reform(data(12,*))
kverr=reform(data(13,*))
kg=reform(data(14,*))
kgerr=reform(data(15,*))
return
end
  
file='/data/pth/G3526/NBI/ALL/LASILLA/lasilla_77_92.dat'
data=get_data(file)
extract_data,data,date,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr
histo,kv,0,1,0.01
xxx=get_kbrd()
; filter the data
idx=where(hjd gt 44322. and hjd lt 45052.)
data=data(*,idx)
extract_data,data,date,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr
histo,kv,0,1,0.01
xxx=get_kbrd()
n=n_elements(kg)
; start fitting
wave=[3464.,4015.,4227.,4476.,5395.,5488.,5807.]
o3_corr=[.016,0.0,0.0,0.01,.025,.030,.039]
fita=[1,1,1,1]
icount=0
for i=0,n-1,1 do begin
	x=wave/10000.0d0
	y=[ku(i),kb1(i),kb(i),kb2(i),kv1(i),kv(i),kg(i)]
;	y=y-o3_corr
	erry=[kuerr(i),kb1err(i),kberr(i),kb2err(i),kv1err(i),kverr(i),kgerr(i)]/1000.0d0
;
	a=randomu(seed,4)/10.
	a(1)=-4.05
	a(3)=-1.36
	yfit= LMFIT(X, Y, A, MEASURE_ERRORS=erry, /DOUBLE, $  
   		FITA = fita, FUNCTION_NAME = 'extinction',convergence=convergence, $
		iter=iterations,itmax=1000) 
;	if (convergence eq 1) then print,'Converged' 
;	if (convergence eq 0) then print,'Not Converged' 
;	if (convergence eq -1) then print,'SIngular matric and Not Converged' 
	residuals=y-yfit
	RMSE=sqrt(total(residuals^2)/n_elements(y))
	if (a(0) gt 0 and a(2) gt 0 and a(3) lt 0 and convergence eq 1) then begin
	;plot,x,y,xtitle='Wavelength',ytitle='Extinction (mags)',psym=3
	;oploterr,x,y,erry
	;oplot,x,yfit	
	print,format='(4(1x,f8.3),1x,f8.3)',a,RMSE
	if (icount eq 0) then begin
	alfa_RC= a(1)
	alfa_p= a(3)
	endif
	if (icount gt 0) then begin
	alfa_RC=[alfa_RC,a(1)]
	alfa_p=[alfa_p,a(3)]
	endif
	icount=icount+1
	endif	
endfor
!P.MULTI=[0,1,2]
minval=min([alfa_rc,alfa_p])
maxval=max([alfa_rc,alfa_p])
histo,alfa_RC,minval,maxval,0.5,title='!7a!3!dRC!n'
histo,alfa_p,minval,maxval,0.5,title='!7a!3!dp!n'
end
