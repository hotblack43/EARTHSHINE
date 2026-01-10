!P.CHARSIZE=2
; cloud free case
data=get_data('eshine_cloudfree_2455917.dat')
jd=reform(data(0,*))
esh=reform(data(1,*))
ph1=reform(data(2,*))
ph2=reform(data(3,*))
plot,jd-long(min(jd)),esh,xtitle='Fractional JD',ytitle='Eshine',title='Uniform Earth: solid; Cloud-free: dashed',linestyle=2
; uniform case
data=get_data('eshine_uniform_2455917.dat')
jd=reform(data(0,*))
esh=reform(data(1,*))
ph1=reform(data(2,*))
ph2=reform(data(3,*))
oplot,jd-long(min(jd)),esh,linestyle=0
;
plots,[0.12,0.12],[!Y.crange],linestyle=1
plots,[0.18,0.18],[!Y.crange],linestyle=1
end
