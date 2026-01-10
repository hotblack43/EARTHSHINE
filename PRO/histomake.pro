data=get_data('aha')
mn=reform(data(0,*))
sd=reform(data(1,*))
med=reform(data(2,*))
!P.MULTI=[0,2,2]
histo,mn,-10,10,1,xtitle='Mean difference'
histo,med,-1,1,.03,xtitle='Median difference'
end

