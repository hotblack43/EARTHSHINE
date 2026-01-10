data=get_data('fitting_sol.dat')
alfa=reform(data(0,*))
offset=reform(data(1,*))
factor=reform(data(2,*))
SSE=reform(data(3,*))
SSE_SD=reform(data(4,*))
!P.multi=[0,1,2]
;plot,alfa,offset,xstyle=3,ystyle=3
;plot,alfa,factor,xstyle=3,ystyle=3
plot,alfa,sse,xstyle=3,ystyle=3,xtitle='SS albedo',ytitle='Error on DS';,yrange=[0.0,0.1]
oploterr,alfa,sse,SSE_SD
rise=mean(SSE_SD)
plots,[!x.crange],[rise,rise],linestyle=2
end
