; learn from TTAURI moonrising from the horizon
data=get_data('circle_seqeunce.dat')
k=2700
!P.MULTI=[0,1,3]
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
plot,reform(data(2,0:k)),ystyle=3,ytitle='Radius [pixels]',xtitle='Image number',charsize=2,title='Moon rising from horizon',xstyle=3
plot,reform(data(0,0:k)),reform(data(1,0:k)),psym=3,xstyle=3,ystyle=3,ytitle='y!d0!n [pixel]',xtitle='x!d0!n [pixel]'
; determine SD of radius
res=linfit(findgen(n_elements(reform(data(2,0:k)))),reform(data(2,0:k)),yfit=yhat)
residuals=reform(data(2,0:k))-yhat
print,'SD of radius:',stddev(residuals)
; refraction
res=linfit(reform(data(0,0:k)),reform(data(1,0:k)),yfit=yhat)
deviation=reform(data(1,0:k))-yhat
plot,reform(data(0,0:k)),deviation,psym=7,xstyle=3,ystyle=3,ytitle='Deviation from linear fit [pixel]',xtitle='x!d0!n [pixel]'

end
