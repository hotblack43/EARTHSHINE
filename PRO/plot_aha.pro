file='aha'
data=get_data(file)
R=reform(data(0,*))
L=reform(data(1,*))
plot,l,r,charsize=2,psym=7,xstyle=1,ystyle=1,xrange=[8,14],yrange=[40,220], $
xtitle='Periode i År',ytitle='Max. antal pletter',title='Lange perioder har lav aktivitet'
end
