file='lunar_az_limits.dat'
data=get_data(file)
lat=reform(data(0,*))
minaz=reform(data(1,*))
maxaz=reform(data(2,*))
plot,lat,minaz,xrange=[0,50],yrange=[1,359], $
xtitle='Latitude',ytitle='max and min range of lunar azimuth',charsize=2, $
psym=-7,ystyle=1
oplot,lat,maxaz, $
psym=-7
plots,[!X.crange],[90,90],linestyle=2
plots,[!X.crange],[180,180],linestyle=2
plots,[!X.crange],[270,270],linestyle=2
end
