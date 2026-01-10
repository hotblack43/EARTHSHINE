!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
phase=findgen(360)-180.
k=phase*0.0
idx=where(abs(phase) le 90)
k(idx)=0.5*(1.+cos(abs(phase(idx))*!dtor))
idx=where(abs(phase) gt 90 and abs(phase) le 180)
k(idx)=0.5*(1.+cos(abs(phase(idx))*!dtor))
plot,phase,k,xtitle='Phase!dE!n',ytitle='k'
end
