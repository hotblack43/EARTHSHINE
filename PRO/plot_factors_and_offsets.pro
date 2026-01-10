data=get_data('factors_and_offsets.dat')
fe=reform(data(0,*))
oe=reform(data(1,*))
fb=reform(data(2,*))
ob=reform(data(3,*))
!P.CHARSIZE=2
!P.thick=2
!x.thick=2
!y.thick=2
plot,fe,fb,xtitle='f EFM',ytitle='f BBSO-lin',psym=7,/isotropic
end
