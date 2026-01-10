data=get_data('FFM.results')
alfa=reform(data(0,*))
a=reform(data(1,*))
b=reform(data(2,*))
err1=abs(reform(data(3,*)))
err2=abs(reform(data(4,*)))
err3=abs(reform(data(5,*)))
plot_oo,xstyle=3,ystyle=3,err2,err3,xtitle='Error on fitted model against observation',ytitle='Error between truth and best fitting model',psym=7,title='0.01 bias added'
;plot_io,xstyle=3,ystyle=3,err2,err3,xrange=[100,200],yrange=[0.01,3],xtitle='% Error on fitted model against observation',ytitle='% Error between truth and best fitting model',psym=7,title='0.01 bias added'
end
