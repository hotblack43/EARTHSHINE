file='testimagestats.dat'
data=get_data(file)
jd=double(reform(data(0,*)))-double(julday(11,03,2009,12,0,0))
mn=reform(data(5,*))
var=reform(data(6,*))
skew=reform(data(7,*))
curt=reform(data(8,*))
idx=where(jd gt 0)
jd=jd(idx)
mn=mn(idx)
var=var(idx)
skew=skew(idx)
curt=curt(idx)
idx=sort(jd)
jd=jd(idx)
mn=mn(idx)
var=var(idx)
skew=skew(idx)
curt=curt(idx)
;
!P.MULTI=[0,1,2]
plot,jd,mn,charsize=2,xtitle='Days since Nov 3 2009 at noon',ytitle='Mean image value'
plot,jd,var,charsize=2,xtitle='Days since Nov 3 2009 at noon',ytitle='Image variance'
end
