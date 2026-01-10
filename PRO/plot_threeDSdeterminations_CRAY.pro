FUNCTION illumfrac,phaseangleindegrees
k=cos(phaseangleindegrees*!dtor/2.)^2
return,k
end

PRO getdata,file,daynum,diff
data=get_data(file)
DScorr=reform(data(0,*))
DStrue=reform(data(1,*))
DSobs=reform(data(2,*))
x0=reform(data(3,*))
y0=reform(data(4,*))
radius=reform(data(5,*))
daynum=reform(data(6,*))
daynum=daynum*9./24.+11.        ; check each time used!
daynum=daynum mod 29.5
diff=(DScorr-DStrue)/DStrue*100.
diff=abs(diff)
return
end


;----------------------------------------------------------
!P.CHARSIZE=1.2
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.MULTI=[0,1,1]
;--------
tstr='500 realistic images coadded, !7a!3=1.8'
file1='threeetc_23_efm_18500.dat'
file2='threeetc_45_efm_18500.dat'
;--------
tstr='1 realistic image, !7a!3=1.8'
file1='threeetc_23_efm_181.dat'
file2='threeetc_45_efm_181.dat'
;--------
tstr='1 realistic image, !7a!3=1.6'
file1='threeetc_23_efm_161.dat'
file2='threeetc_45_efm_161.dat'
;--------
tstr='500 realistic images coadded, !7a!3=1.6'
file1='threeetc_23_efm_16500.dat'
file2='threeetc_45_efm_16500.dat'
;--------
iftype=2	; 1 or 2 - 1is with time as x axis, 2 is with lunar phase as x axis
if (iftype eq 1) then begin
getdata,file1,daynum,diff_23_efm_18500
phaseangleindegrees=daynum/29.7*360-180
phases=illumfrac(phaseangleindegrees)
plot_io,/nodata,xstyle=3,daynum,(diff_23_efm_18500),xtitle='Day',$
psym=7,ytitle='Absolute error [%]',xrange=[5,24],$
yrange=[1e-2,1e3]
oplot,daynum,(diff_23_efm_18500),color=fsc_color('red'),psym=7
oplot,[!x.crange],[0,0],linestyle=1
;................
getdata,file2,daynum,diff_45_efm_18500
oplot,daynum,(diff_45_efm_18500),color=fsc_color('blue'),psym=7
oplot,[!x.crange],[0,0],linestyle=1
;................
xyouts,/normal,0.15,-0.3,'Blue: 4/5. Red: 2/3',charsize=1.0
xyouts,/normal,0.15,-0.4,tstr
endif
if (iftype eq 2) then begin
;-------------- same plots but with lunar phase as X
getdata,file1,daynum,diff_23_efm_18500
synodic=29.7
phases=daynum/synodic*360-180
plot_io,/nodata,xstyle=3,phases,(diff_23_efm_18500),$
xtitle='Lunar Phase angle (New Moon at 0)',$
psym=7,ytitle='Absolute error [%]',$
yrange=[1e-2,1e3],xrange=[-120,120]
oplot,phases,(diff_23_efm_18500),color=fsc_color('red'),psym=7
oplot,[!x.crange],[0,0],linestyle=1
;................
getdata,file2,daynum,diff_45_efm_18500
phases=daynum/synodic*360-180
oplot,phases,(diff_45_efm_18500),color=fsc_color('blue'),psym=7
oplot,[!x.crange],[0,0],linestyle=1
;................
xyouts,/normal,0.15,-0.3,'Blue: 4/5. Red: 2/3',charsize=1.0
xyouts,/normal,0.15,-0.4,tstr
endif
end

