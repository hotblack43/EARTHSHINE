im=readfits('rotatedim.fits')
lhs=im(0:252,*)
rhs=im(254:511,*)
;
!P.MULTI=[0,1,2]
plot_io,total(lhs(*,261-5:261+5),2)/11.+11.,yrange=[1,1e4],xrange=[200,260],charsize=2,title='SKE DS',xtitle='Column',ytitle='Counts'
print,'MAX on lhs: ',max(total(lhs(*,261-5:261+5),2)/11.)
oplot,[!X.crange],[10,10]
plot_io,total(rhs(*,261-5:261+5),2)/11.,yrange=[300,3e3],xrange=[0,60],charsize=2,title='SKE BS',xtitle='Column',ytitle='Counts',ystyle=1
print,'MAX on rhs: ',max(total(rhs(*,261-5:261+5),2)/11.)
end
