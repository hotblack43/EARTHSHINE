data=get_data('differential_airmass.dat')
dam=reform(data(1,*))
!P.charsize=2
!Y.STYLE=3          
!Y.STYLE=3 
histo,dam,-0.01,0.4,.01,/abs,xtitle='Differential airmass'
xyouts,/data,0.1,180,'Median: '+string(median(dam),format='(f6.4)')
xyouts,/data,0.1,160,'Max: '+string(max(dam),format='(f4.2)')
end

