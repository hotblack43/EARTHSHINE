file='all_halo_slopes.dat'
data=get_data(file)
slope=abs(reform(data(1,*)))
err_slope=reform(data(2,*))
AOD=reform(data(4,*))
; get  only the best
z=abs(slope/err_slope)
idx=where(z gt 100 and AOD gt 0)
data=data(*,idx)
;
jd=reform(data(0,*))
slope=abs(reform(data(1,*)))
err_slope=reform(data(2,*))
err=reform(data(3,*))
AOD=reform(data(4,*))
;------------------
plot,xtitle='AERONET abs coeff',ytitle='Power',xstyle=3,ystyle=3,AOD,slope,psym=7
res=robust_linefit(AOD,slope,yhat,sig,coef_sig)
print,'Robust slope: ',res(1),' +/- ',coef_sig(1)
print,'Z: ',abs(res(1)/coef_sig(1))
oplot,AOD,yhat,color=fsc_color('red')
;
res2=ladfit(AOD,slope)
print,res2
yhat2=res2(0)+res2(1)*AOD
oplot,AOD,yhat2,color=fsc_color('green')
end
