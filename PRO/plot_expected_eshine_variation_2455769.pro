!P.CHARSIZE=2
!P.CHARTHICK=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
data=get_data('expected_eshine_variation_2455769.dat')
jd=reform(data(0,*))
eShine=reform(data(1,*))
ph_E=reform(data(2,*))
 time_start=2455769.0822d0-long(jd(0))
 time_stop=2455769.11434d0-long(jd(0))
idx=where(jd ge time_start and jd le time_stop)
!P.MULTI=[0,1,2]
plot,jd-long(jd(0)),eSHine,xtitle='Fr. JD',ytitle='Earthsine intensity',title='Synthetic model data, cloud-free Earth',xstyle=3,ystyle=3
plots,[time_start,time_start],[!Y.crange],linestyle=2
plots,[time_stop,time_stop],[!Y.crange],linestyle=2
plot,jd-long(jd(0)),(eSHine-mean(eShine))/mean(eShine)*100.,xtitle='Fr. JD',ytitle='Change in pct',title='Synthetic model data, cloud-free Earth',xstyle=3,ystyle=3
plots,[time_start,time_start],[!Y.crange],linestyle=2
plots,[time_stop,time_stop],[!Y.crange],linestyle=2
end
