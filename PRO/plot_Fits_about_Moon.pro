file='Fits_about_Moon.txt'
data=get_data(file)
JD1=reform(data(0,*))
JD2=reform(data(1,*))
deltaBmV_Moon=reform(data(2,*))
BmV_BS=reform(data(3,*))
BmV_DS=reform(data(4,*))
errBmV_DS=reform(data(5,*))
JD=(JD1+JD2)/2.0d0
!P.CHARSIZE=1.8
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.MULTI=[0,1,1]
;plot,JD-long(JD),BmV_BS,psym=7,xstyle=3,yrange=[0.8,1.2],xtitle='Frac. JD',ytitle='(B-V)!dBS!n'
histo,/abs,BmV_BS,0.8,1.0,0.01,xtitle='(B-V)!dBS!n'
!X.crange=[0.81,1.0]
!X.style=3
xyouts,0.83,17,'B-V!dBS!n = '+string(mean(BmV_BS),format='(f5.3)')+', !7r!3 = '+string(stddev(BmV_BS),format='(f5.3)')
stop
print,'Mean B-V BS: ',mean(BmV_BS)
print,'S.D.    : ',stddev(BmV_BS)    
print,'Mean B-V DS: ',mean(BmV_DS)
print,'S.D.    : ',stddev(BmV_DS)    
histo,BmV_BS-BmV_DS,0.1,0.5,0.02,xtitle='(B-V)!dBS!n-(B-V)!dDS!n'
print,'Mean (B-V BS - B-V DS) : ',mean(BmV_BS-BmV_DS)
print,'Median (B-V BS - B-V DS) : ',median(BmV_BS-BmV_DS)
print,'S.D.    : ',stddev(BmV_BS-BmV_DS)    
;
mphase,jd,k
!P.MULTI=[0,1,3]
plot,xstyle=3,jd,BmV_BS-BmV_DS,psym=7,xtitle='JD',ytitle='B-V (BS - DS)'
plot,xstyle=3,k,BmV_BS-BmV_DS,psym=7,xtitle='illuminated fraction',ytitle='B-V (BS - DS)'
plot,xstyle=3,JD-long(jd),BmV_BS-BmV_DS,psym=7,xtitle='fractional day',ytitle='B-V (BS - DS)'
;
plot,BMV_BS,BMV_DS,psym=7,xtitle='B-V BS',ytitle='B-V DS',xstyle=3,ystyle=3
res=ladfit(BMV_BS,BMV_DS)
yhat=res(0)+res(1)*BMV_BS
oplot,BMV_BS,yhat,color=fsc_color('red')
res=linfit(BMV_BS,BMV_DS,yfit=yhat2)    
oplot,BMV_BS,yhat2,color=fsc_color('blue')

end
