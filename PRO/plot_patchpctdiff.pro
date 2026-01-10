;data=get_data('patchpctdiff_2over3.dat')
data=get_data('patchpctdiff_3over4.dat')
;data=get_data('patchpctdiff_4over5.dat')
alfa=reform(data(0,*))
jd=reform(data(1,*))
k=reform(data(2,*))
ds=reform(data(3,*))
pct=reform(data(4,*))
maxpct=reform(data(5,*))
!P.CHARSIZE=2
!P.MULTI=[0,1,2]
plot_io,xstyle=3,ystyle=3,jd-jd(0),ds,ytitle='DS intensity',psym=7
plot,xstyle=3,ystyle=3,jd-jd(0),pct,ytitle='% diff in ref patch',psym=7
;
!P.MULTI=[0,1,1]
plot_io,xstyle=3,ystyle=3,k,abs(pct),ytitle='abs % diff in ref patch',psym=7,xtitle='Illuminated fraction'
for cut=0.1,1.0,0.2 do begin
oplot,[!X.CRANGE],[cut,cut],linestyle=2
endfor
end

