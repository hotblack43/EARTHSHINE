filternames=['B','IRCUT','V','VE1','VE2']
data=get_data('ratrats.dat')
ibrdf=reform(data(0,*))
ifilt=reform(data(1,*))
k=reform(data(2,*))
ratio=reform(data(3,*))
;
!P.MULTI=[0,2,3]
for ifil=0,4,1 do begin
idx=where(ifilt eq ifil and ratio gt 0.5)
plot_io,ystyle=3,k(idx),ratio(idx),psym=7,xtitle='k',ytitle='crat/rat',title=filternames(ifil),charsize=1.8
endfor
end
