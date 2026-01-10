file='fits.dat'
data=get_data(file)
hjd=reform(data(0,*))
brc=reform(data(1,*))
alfarc=reform(data(2,*))
bp=reform(data(3,*))
alfap=reform(data(4,*))
factor=reform(data(5,*))
rmse=reform(data(6,*))
;idx=where(alfap lt 0 and bp ne 0 and alfarc ne -13 and rmse lt 0.01)
idx=where(alfap lt 3 and rmse lt 0.005)
data=data(*,idx)
hjd=reform(data(0,*))
brc=reform(data(1,*))
alfarc=reform(data(2,*))
bp=reform(data(3,*))
alfap=reform(data(4,*))
factor=reform(data(5,*))
rmse=reform(data(6,*))
!P.MULTI=[0,1,5]
!P.CHARSIZE=1.8
plot,hjd,rmse,xtitle='HJD',ytitle='RMSE',psym=4,charsize=2
plot,hjd,brc,xtitle='HJD',ytitle='Factor on Rayleigh',psym=4,charsize=2,ystyle=1
plot,hjd,alfarc,xtitle='HJD',ytitle='Power in Rayleigh',psym=4,charsize=2,ystyle=1
plot,hjd,bp,xtitle='HJD',ytitle='Factor on Aerosol',psym=4,charsize=2
plot,hjd,alfap,xtitle='HJD',ytitle='!7a!3!dp!n',psym=4,charsize=2
!P.MULTI=[0,1,2]
histo,alfap,-4,4,0.25,xtitle='!7a!3!dp!n'
print,median(alfap),mean(alfap)
histo,alfarc,-12,0,0.25,xtitle='!7a!3!dRC!n'
print,median(alfarc),mean(alfarc)

end
