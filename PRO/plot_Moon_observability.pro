file='Moon.data'
data=get_data(file)
q=reform(data(0,*))
lat=reform(data(1,*))
plot,lat,q,xtitle='Latitude',ytitle='Q (arb. units)',psym=-7,charsize=2,xrange=[0,90],xstyle=1
plots,[66.5,66.5],[!Y.CRANGE]
end
