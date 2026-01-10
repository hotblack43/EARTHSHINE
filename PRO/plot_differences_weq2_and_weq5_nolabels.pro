!P.MULTI=[0,2,2]
!P.THICK=2
!x.THICK=2
!y.THICK=2
data=get_data('differene_RUN1_RUN2.dat')
jd=reform(data(0,*))
diff=reform(data(1,*))
!P.CHARSIZE=1.1
histo,diff,-0.01,0.01,0.0010,title='32b: Effect of 5x5 vs. 11x11 patch on sky',xtitle='Difference in !7a!3'
plots,[0,0],[!Y.crange],linestyle=2
print,'min,max difference: ',min(diff),max(diff)
print,'% alfa changes outside +/- 0.01: ',float(n_elements(where(abs(diff) gt 0.01)))/n_elements(diff)*100.
;
data=get_data('differene_RUN2_RUN3.dat')
jd=reform(data(0,*))
diff=reform(data(1,*))
histo,diff,-0.001,0.001,0.0001,title='11x11: Effect of 32bit vs 64bit',xtitle='Difference in !7a!3'
plots,[0,0],[!Y.crange],linestyle=2
print,'min,max difference: ',min(diff),max(diff)
print,'% alfa changes outside +/- 0.01: ',float(n_elements(where(abs(diff) gt 0.01)))/n_elements(diff)*100.
;
data=get_data('differene_RUN2_RUN5.dat')
jd=reform(data(0,*))
diff=reform(data(1,*))
histo,diff,-0.01,0.01,0.0001,title='32b, Effect of 1 vs 2 iterstions',xtitle='Difference in !7a!3'
plots,[0,0],[!Y.crange],linestyle=2
print,'min,max difference: ',min(diff),max(diff)
print,'% alfa changes outside +/- 0.01: ',float(n_elements(where(abs(diff) gt 0.01)))/n_elements(diff)*100.
end
