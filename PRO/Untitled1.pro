file='fits.dat'
data=get_data(file)
hjd=reform(data(0,*))
brc=reform(data(1,*))
alfarc=reform(data(2,*))
bp=reform(data(3,*))
alfap=reform(data(4,*))
factor=reform(data(5,*))
rmse=reform(data(6,*))
idx=where(rmse le 0.2 and alfap lt 3 and brc ne 0)
data=data(*,idx)
hjd=reform(data(0,*))
brc=reform(data(1,*))
alfarc=reform(data(2,*))
bp=reform(data(3,*))
alfap=reform(data(4,*))
factor=reform(data(5,*))
rmse=reform(data(6,*))
!P.MULTI=[0,1,3]
plot,hjd,brc,xtitle='HJD',ytitle='Factor on Rayleigh',psym=4,charsize=2
plot,hjd,bp,xtitle='HJD',ytitle='Factor on Aerosol',psym=4,charsize=2
plot,hjd,alfap,xtitle='HJD',ytitle='!7a!3!dp!n',psym=4,charsize=2
end
