o3_corr=[.016d0,0.0d0,0.0d0,0.01d0,.025d0,.030d0,.039d0]
wave=[3464.,4015.,4227.,4476.,5395.,5488.,5807.]
wave=wave/10000.0d0
file='lasilla_77_92_stripped.dat'
data=get_data(file)
time=reform(data(0,*))
data=data(1:7,*)
;data=10^(-data/2.5)
; remove mean, if you like
;for k=0,6,1 do data(k,*)=data(k,*)-mean(data(k,*))
; normalize, if you like
;for k=0,6,1 do data(k,*)=data(k,*)/stddev(data(k,*))
!P.MULTI=[0,1,7]
for k=0,6,1 do plot,data(k,*),xtitle='Day',ytitle='Geneva band absorbtion [mags]',yrange=[min(data),max(data)]
nmodes=3
eofs=eofunc(data,pc=pc,var=var,nmodes=nmodes, $
covariance=1,eigenvalues=eigenvalues, $
reconstr=reconstr,scale=3)
help,eofs
; plot the variance explained
!p.multi=[0,1,1]
plot_io,var*100.0,xtitle='Mode #',title='% variance explained'
; Plot the PCs
!p.multi=[0,1,nmodes]
for i=1,nmodes,1 do begin
plot,time,pc(i-1,*),title='PC # '+string(i)
endfor
; plot the eofs
for i=1,nmodes,1 do begin
plot,wave,eofs(*,i-1), $
title='EOF # '+string(i),psym=10,$
xtitle='Wavelength',yrange=[-1,1],ytitle='mags'
oplot,wave,eofs(*,i-1),psym=7
;if (i eq 3) then begin
;oplot,wave,20.*o3_corr,psym=10,color=fsc_color('red')
;endif
if (i eq 1) then begin
res=linfit(wave,eofs(*,i-1),yfit=yhat,/double)
print,res
oplot,wave,yhat,color=fsc_color('red')
xyouts,/data,0.35,0.8,'Slope: '+string(res(1))
endif
if (i eq 2) then begin
res=linfit(wave,eofs(*,i-1),yfit=yhat,/double)
print,res
oplot,wave,yhat,color=fsc_color('red')
xyouts,/data,0.35,0.8,'Slope: '+string(res(1))
endif
plots,[!X.CRANGE],[0,0],linestyle=2
endfor
print,'Variance explained bymodes: ',var
end
