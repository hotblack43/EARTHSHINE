PRO plotconnext,daynum1,diff1,daynum2,diff2,linstyl
for i=0,n_elements(daynum1)-1,1 do oplot,[daynum1(i),daynum2(i)],[diff1(i),diff2(i)],linestyle=linstyl
return
end
FUNCTION illumfrac,phaseangleindegrees
k=cos(phaseangleindegrees*!dtor/2.)^2
return,k
end

PRO getdata,file,daynum,arr1,arr2
;JD                     alfa           offset         err1          err2         err3         err4
data=get_data(file)
JD=reform(data(0,*))
alfa=reform(data(1,*))
offset=reform(data(2,*))
errwrtidealinfixedboxinpct=reform(data(3,*))
biaswrtidealinfixedboxinpct=reform(data(4,*))
DSresidualat23inpct=reform(data(5,*))
DSresidualat45inpct=reform(data(6,*))
daynum=(JD-2445917.0d0)+11.        ; check each time used!
daynum=daynum mod 29.5
arr1=DSresidualat23inpct
arr2=DSresidualat45inpct
return
end


;----------------------------------------------------------
!P.CHARSIZE=1.2
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.MULTI=[0,1,1]
;--------
tstr='EFM: 100 realistic images coadded, !7a!3=1.6'
file1='collected_output_EFM_100ims_1p6.txt'
;--------
tstr='EFM: 100 realistic images coadded, !7a!3=1.8'
file1='collected_output_EFM_100ims_1p8.txt'
file1='collected_output_EFM_100ims_1p8_b.txt'
file1='collected_output_EFM_realimages.txt'
;--------
getdata,file1,daynum,arr,arr2
synodic=29.7
phases=daynum/synodic*360-180
plot_io,/nodata,xstyle=3,phases,abs(arr),$
xtitle='Lunar Phase angle (New Moon at 0)',$
psym=7,ytitle='Absolute error [%]',$
xrange=[-120,120],yrange=[.01,1000]
oplot,phases,(abs(arr)),psym=4
oplot,[!x.crange],[1,1],linestyle=2
oplot,phases,(abs(arr2)),psym=7
plotconnext,phases,arr,phases,arr2,2
;................
end
