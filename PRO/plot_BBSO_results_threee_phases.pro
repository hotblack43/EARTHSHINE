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
diff=(DScorr-DStrue)/DStrue*100.
diff=abs(diff)
return
end

!P.CHARSIZE=1.2
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.MULTI=[0,1,1]
synodic=29.5
;--------
tstr='1 realistic image, !7a!3=1.6'
getdata,'PAPER/DATA/threeetc_23_nolog_1p6_1.dat',DScorr,DStrue,DSobs,x0,y0,radius,daynum1,diff1
phases1=daynum1/synodic*360-180
plot_io,/nodata,xstyle=3,phases1,(diff1),xtitle='Lunar phase, New Moon at 0',$
psym=7,ytitle='Error [%]',xrange=[-120,120],$
;psym=7,ytitle='Absolute error [%]',xrange=[-120,120],$
yrange=[1e-2,1e3]

oplot,phases1,(diff1),color=fsc_color('red'),psym=4
oplot,[!x.crange],[0,0],linestyle=1
;...............
getdata,'PAPER/DATA/threeetc_23_yeslog_1p6_1.dat',DScorr,DStrue,DSobs,x0,y0,radius,daynum2,diff2
phases2=daynum2/synodic*360-180
oplot,phases2,(diff2),color=fsc_color('blue'),psym=4
plotconnext,phases1,diff1,phases2,diff2,1
;======================================================================================
getdata,'PAPER/DATA/threeetc_35_nolog_1p6_1.dat',DScorr,DStrue,DSobs,x0,y0,radius,daynum1,diff1
phases1=daynum1/synodic*360-180
oplot,phases1+0.45,(diff1),color=fsc_color('red'),psym=7
;...............
getdata,'PAPER/DATA/threeetc_35_yeslog_1p6_1.dat',DScorr,DStrue,DSobs,x0,y0,radius,daynum2,diff2
phases2=daynum2/synodic*360-180
oplot,phases2+0.45,(diff2),color=fsc_color('blue'),psym=7
plotconnext,phases1+0.45,diff1,phases2+0.45,diff2,0
;...............
oplot,[!x.crange],[1.0,1.0],linestyle=2
xyouts,/normal,0.15,-0.2,'Blue: log. Red: linear',charsize=1.0
xyouts,/normal,0.15,-0.3,'Cross: 4/5. Diam: 2/3',charsize=1.0
xyouts,/normal,0.15,-0.4,tstr
xyouts,/normal,0.15,-0.5,'BBSO methods'
end
