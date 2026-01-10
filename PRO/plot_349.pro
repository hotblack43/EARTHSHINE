im=readfits('stacked_new_349_float.FIT')
;plot_io,im(*,260),charsize=2,ytitle='Counts',xtitle='pixel column',title='along row through centre',xstyle=1
;plots,[283.5,283.5],[1,1e5]
;plots,[64.7,64.7],[1,1e5]
;x=indgen(430)
;oplot,x,2.9*10^(x/208.)
;
plot_io,total(im(*,255:265),2),charsize=2,ytitle='Counts',xtitle='pixel column',title='along row through centre',xstyle=1,xrange=[0,150]
plots,[283.5,283.5],[10,1e3]
plots,[64.7,64.7],[10,1e3]
x=indgen(430)
oplot,x,28.8*10^(x/311.)

end
