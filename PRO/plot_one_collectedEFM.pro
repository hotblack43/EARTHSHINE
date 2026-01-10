!P.thick=4
!x.thick=2
!y.thick=2
night='2456003'
file=strcompress('collected_output_EFM_realimages_'+night+'.txt',/remove_all)
; get data for V filter
filter='_B_'
spawn,'grep '+filter+' '+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > aha.dat"
data=get_data('aha.dat')
alfa=reform(data(1,*))
am=reform(data(10,*))
plot,title=night+' : '+'Estimates of !7a!3!dinstrumental!n',$
psym=7,ystyle=3,xrange=[0,4],yrange=[1.705,1.76],xstyle=3,$
am,alfa,xtitle='Airmass',ytitle='!7a!3',charsize=1.5
res=linfit(am,alfa,/double,sigma=sigs)
print,'B   intercept: ',res(0),' +/- ',sigs(0)
x=[0.0,am]
yhat=res(0)+res(1)#x
oplot,x,yhat,color=fsc_color('blue')
; get data for V  filter
filter='_V_'
spawn,'grep '+filter+' '+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > aha.dat"
data2=get_data('aha.dat')
alfa=reform(data2(1,*))
am=reform(data2(10,*))
oplot,psym=7,am,alfa,color=fsc_color('green')
res=linfit(am,alfa,/double,sigma=sigs)
print,'V   intercept: ',res(0),' +/- ',sigs(0)
x=[0.0,am]
yhat=res(0)+res(1)#x
oplot,x,yhat,color=fsc_color('green')
; get data for VE1  filter
filter='_VE1_'
spawn,'grep '+filter+' '+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > aha.dat"
data2=get_data('aha.dat')
alfa=reform(data2(1,*))
am=reform(data2(10,*))
oplot,psym=7,am,alfa,color=fsc_color('yellow')
res=linfit(am,alfa,/double,sigma=sigs)
print,'VE1 intercept: ',res(0),' +/- ',sigs(0)
x=[0.0,am]
yhat=res(0)+res(1)#x
oplot,x,yhat,color=fsc_color('yellow')
; get data for VE2  filter
filter='_VE2_'
spawn,'grep '+filter+' '+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > aha.dat"
data2=get_data('aha.dat')
alfa=reform(data2(1,*))
am=reform(data2(10,*))
oplot,psym=7,am,alfa,color=fsc_color('red')
res=linfit(am,alfa,/double,sigma=sigs)
print,'VE2 intercept: ',res(0),' +/- ',sigs(0)
x=[0.0,am]
yhat=res(0)+res(1)#x
oplot,x,yhat,color=fsc_color('red')
;
plots,[0,0],[!Y.crange],linestyle=2
plots,[0,1],[res(0),1.75],linestyle=1 & xyouts,/data,1.2,1.75,'!7a!3 at zero airmass',charsize=2
end
