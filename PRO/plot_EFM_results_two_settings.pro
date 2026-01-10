PRO plotconnext,daynum1,diff1,daynum2,diff2
for i=0,n_elements(daynum1)-1,1 do oplot,[daynum1(i),daynum2(i)],[diff1(i),diff2(i)],linestyle=1
return
end

PRO getdata,filename,DScorr,DStrue,DSobs,daynum,diff
data=get_data(filename)
DScorr=reform(data(0,*))
DStrue=reform(data(1,*))
DSobs=reform(data(2,*))
daynum=reform(data(3,*))
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
tstr='EFM, 1 realistic image, !7a!3=1.8'
getdata,'PAPER/DATA/threeetc_1_1p8_EFM_iflag1.dat',DScorr,DStrue,DSobs,daynum1,diff1
plot_io,xrange=[5,20],/nodata,xstyle=3,daynum1,(diff1),xtitle='Day',$
psym=7,ytitle='|(T-C)/T*100| [%]',yrange=[.1,25],title=tstr,max=99.99
oplot,daynum1,(diff1),psym=7,color=fsc_color('red')
getdata,'PAPER/DATA/threeetc_1_1p8_EFM_iflag2.dat',DScorr,DStrue,DSobs,daynum2,diff2
oplot,daynum2,(diff2),psym=6,color=fsc_color('red')
plotconnext,daynum1,diff1,daynum2,diff2
end
