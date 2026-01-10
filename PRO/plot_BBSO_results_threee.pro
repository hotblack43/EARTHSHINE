PRO plotconnext,daynum1,diff1,daynum2,diff2,linstyl
for i=0,n_elements(daynum1)-1,1 do oplot,[daynum1(i),daynum2(i)],[diff1(i),diff2(i)],linestyle=linstyl
return
end

PRO getdata,filename,DScorr,DStrue,DSobs,x0,y0,radius,daynum,diff
data=get_data(filename)
DScorr=reform(data(0,*))
DStrue=reform(data(1,*))
DSobs=reform(data(2,*))
x0=reform(data(3,*))
y0=reform(data(4,*))
radius=reform(data(5,*))
daynum=reform(data(6,*))
daynum=daynum*9./24.+11.	; check each time used!
daynum=daynum mod 29.5
diff=(DStrue-DScorr)/DStrue*100.
diff=abs(diff)
return
end

!P.CHARSIZE=1.2
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.MULTI=[0,1,1]
;--------
tstr='500 realistic images coadded, !7a!3=1.8'
getdata,'threeetc_23_nolog.dat',DScorr,DStrue,DSobs,x0,y0,radius,daynum1,diff1
plot_io,/nodata,xstyle=3,daynum1,(diff1),xtitle='Day',$
psym=7,ytitle='Absolute error [%]',xrange=[5,24],$
yrange=[1e-2,1e3]

oplot,daynum1,(diff1),color=fsc_color('red'),psym=4
oplot,[!x.crange],[0,0],linestyle=1
;...............
getdata,'threeetc_23_yeslog.dat',DScorr,DStrue,DSobs,x0,y0,radius,daynum2,diff2
oplot,daynum2,(diff2),color=fsc_color('blue'),psym=4
plotconnext,daynum1,diff1,daynum2,diff2,1
;======================================================================================
getdata,'threeetc_35_nolog.dat',DScorr,DStrue,DSobs,x0,y0,radius,daynum1,diff1
oplot,daynum1+0.25,(diff1),color=fsc_color('red'),psym=7
;plotconnext,daynum1+0.25,diff1,daynum2+0.25,diff2,0
;...............
getdata,'threeetc_35_yeslog.dat',DScorr,DStrue,DSobs,x0,y0,radius,daynum2,diff2
oplot,daynum2+0.25,(diff2),color=fsc_color('blue'),psym=7
plotconnext,daynum1+0.25,diff1,daynum2+0.25,diff2,0
;...............
xyouts,/normal,0.15,-0.2,'Blue: log. Red: linear',charsize=1.0
xyouts,/normal,0.15,-0.3,'Cross: 3/5. Diam: 2/3',charsize=1.0
xyouts,/normal,0.15,-0.4,tstr
end
