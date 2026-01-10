

PRO go_fit_line,filename,intercept,slope,radius,res,p
; will fit a straight line to th edata in
data=get_data(filename)
number=reform(data(0,*))
theta=reform(data(1,*))
x=reform(data(2,*))
y=reform(data(3,*))
sigs=reform(data(4,*))
idx=where(x gt radius)
res=linfit(x(idx),y(idx),sigma=par_sigs,/double,yfit=yfit,measure_errors=sigs(idx),prob=p)
print,res
window,1,xsize=400,ysize=300
plot,x(idx),y(idx),psym=7,ystyle=1,title='Angle='+string(theta(0)),xtitle='Distance from Moon ctr.'
errplot,x(idx),y(idx)-sigs(idx),y(idx)+sigs(idx)
oplot,x(idx),yfit
if (p gt 0.1) then print,p,' a probable good fit'
if (p le 0.1) then print,p,' NOT a good fit'
return
end
