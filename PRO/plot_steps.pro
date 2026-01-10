!P.MULTI=[0,1,2]
data=get_data('steps.dat')
phase=reform(data(5,*))
idx=where(abs(phase) gt 40 and abs(phase) lt 140)
data=data(*,idx)
JD=reform(data(0,*));
DSstep=reform(data(1,*))
sig1=reform(data(2,*))
BSstep=reform(data(3,*))
sig2=reform(data(4,*))
phase=reform(data(5,*))
iearth=reform(data(6,*))
;
signature_eshine=sig1/sig2
step_eshine=DSstep/BSstep
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.CHARTHICK=2
;plot_io,phase,iearth,psym=7,xtitle='Lunar phase [FM = 0]',ytitle='I!dearth!n {W/m!u2!n]'
plot_oo,signature_eshine,step_eshine,psym=7,xtitle='I!dearth!n from laplacian DS/BS ratio',ytitle='I!dearth!n from stepsize DS/BS ratio'
plots,[1e-6,1e-2],[1e-6,1e-2],linestyle=2
plot_oo,signature_eshine,iearth,psym=7,xtitle='I!dearth!n from laplacian DS/BS ratio',ytitle='I!dearth!n {W/m!u2!n]'
oplot,[1e-6,4e-4],[.002,0.08],linestyle=3
print,1e-6/.002,4e-4/0.08
;
key=''
!P.MULTI=[0,1,1]
period=24.+50.4/60.
while (key ne 'q') do begin
plot_io,jd*24.0 mod period,signature_eshine,psym=-7
key=get_kbrd()
if (key eq 'u') then period=period+.01/3600.
if (key eq 'd') then period=period-.01/3600.
print,fix(period),(period-fix(period))*60.
endwhile
end
