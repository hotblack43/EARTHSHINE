PRO do_residuals,f,g,c_image,shouldbeoriginal,iter,l,old_err
        shouldbeoriginal= double(fft(fft(f,-1)*fft(g,-1),1))
        residuals = c_image - shouldbeoriginal
        rse=sqrt(total(residuals^2))/l(0)/l(1) & print,iter,rse
        window,3,title='residuals',xsize=l(0),ysize=l(1) & tvscl,residuals
         if (rse lt old_err) then begin
; write out the best-yet results
                writefits,'f.fit',double(f)
                writefits,'g.fit',shift(double(g),l(0)/2.,l(1)/2.)
                old_err=rse
         endif
	openw,11,'error.dat',/append
	printf,11,rse,iter
	close,11	
data=get_data('error.dat')
y=reform(data(0,*))
x=reform(data(1,*))
nx=n_elements(x)
if (nx gt 2) then begin
	window,5
	if (nx lt 100) then plot_io,x,y,psym=7,charsize=2,xtitle='Iteration',ytitle='Error per pixel'
	if (nx ge 100) then plot_io,x,y,psym=3,charsize=2,xtitle='Iteration',ytitle='Error per pixel'
endif
return
end
