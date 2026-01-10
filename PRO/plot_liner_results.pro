FUNCTION get_data,filename
data = READ_ASCII(filename)
get_data=data.field1
return,get_data
end

fiel='May25_linearSKYremoval_results.dat'
data=get_data(fiel)
dist=reform(data(0,*))
magn_BBSO=reform(data(1,*))
magn_RAW=reform(data(2,*))
plot,dist,magn_BBSO,psym=7,xtitle='Distance in pixels to Moon disc edge',ytitle='Instrument magn',xstyle=1,ystyle=1,yrange=[11.55,11.3],xrange=[15,130]
oplot,dist,magn_RAW,psym=4
end