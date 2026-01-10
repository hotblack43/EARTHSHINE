PRO plotconnext,daynum1,diff1,daynum2,diff2
for i=0,n_elements(daynum1)-1,1 do oplot,[daynum1(i),daynum2(i)],[diff1(i),diff2(i)],linestyle=1
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
daynum=daynum/3.
diff=(DStrue-DScorr)/DStrue*100.
diff=abs(diff)
return
end

!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.MULTI=[0,1,1]
;--------
getdata,'threeetc_1_run23.dat',DScorr,DStrue,DSobs,x0,y0,radius,daynum1,diff1
plot_io,/nodata,xrange=[5,20],xstyle=3,daynum1,(diff1),xtitle='Day',$
psym=7,ytitle='|(T-C)/T*100| [%]',yrange=[.1,25]
oplot,daynum1,(diff1),color=fsc_color('blue'),psym=7
oplot,[!x.crange],[0,0],linestyle=1
;...............
getdata,'threeetc_2_run23.dat',DScorr,DStrue,DSobs,x0,y0,radius,daynum2,diff2
oplot,daynum2,(diff2),color=fsc_color('red'),psym=7
plotconnext,daynum1,diff1,daynum2,diff2
;...............
getdata,'threeetc_3_run23.dat',DScorr,DStrue,DSobs,x0,y0,radius,daynum3,diff3
oplot,daynum3-0.1,(diff3),color=fsc_color('blue'),psym=6
;...............
getdata,'threeetc_4_run23.dat',DScorr,DStrue,DSobs,x0,y0,radius,daynum4,diff4
oplot,daynum4-0.1,(diff4),color=fsc_color('red'),psym=6
plotconnext,daynum3-0.1,diff3,daynum4-0.1,diff4
;
xyouts,/normal,0.3,0.25,'Blue: log. Red: linear',charsize=1.3
xyouts,/normal,0.3,0.3,'Cross: 4/5. Box: 2/3',charsize=1.3
end
