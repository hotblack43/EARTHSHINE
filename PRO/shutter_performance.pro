data=get_data('shutterdata.dat')
req=reform(data(0,*))
act=reform(data(1,*))
!P.CHARSIZE=1.7
!P.THICK=2
!x.THICK=2
!y.THICK=2
plot_oo,/isotropic,yrange=[1e-6,1],xrange=[1e-6,1],xstyle=3,ystyle=3,req,act,psym=7,xtitle='Requested exposure time [s]',ytitle='Measured exposure time'
oplot,[1e-6,1],[1e-6,1]
print,n_elements(act)
idx=where(act gt 1e-3 and req lt 1)
print,n_elements(idx)
plot_oo,/isotropic,yrange=[1e-3,1],xrange=[1e-3,1],xstyle=3,ystyle=3,req(idx),act(idx),psym=7,xtitle='Requested exposure time [s]',ytitle='Measured exposure time'
oplot,[1e-3,1],[1e-3,1]
;
req=req(idx)
act=act(idx)
sorted=req(sort(req))
types=sorted(uniq(sorted))
for i=0,n_elements(types)-1,1 do begin
idx=where(req eq types(i))
print,format='(f5.2,a,2(f6.2,a))',types(i),' s ',stddev(act(idx))/mean(req(idx))*100.0,' %. Bias:',(mean(act(idx))-mean(req(idx)))/mean(req(idx))*100.,' %.'
endfor
end
