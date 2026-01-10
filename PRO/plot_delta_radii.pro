data=get_data('delta_radii.dat')
;
d1=reform(data(0,*))
d2=reform(data(1,*))
d3=reform(data(2,*))
t1='!7D!3r!dO-JD!n'
t2='!7D!3r!dO-M!n'
t3='!7D!3r!dJD-M!n'
;
!P.MULTI=[0,1,3]
!P.CHARSIZE=2.3
!P.THICK=2
!x.THICK=2
!y.THICK=2
histo,d1,-2,2,0.1,xtitle=t1
histo,d2,-2,2,0.1,xtitle=t2
histo,d3,-2,2,0.1,xtitle=t3
print,'Obs - JD    :',mean(d1),' +/- ',stddev(d1)
print,'Obs - Model :',mean(d2),' +/- ',stddev(d2)
print,'JD - Model  :',mean(d3),' +/- ',stddev(d3)
end
