;RESTORE,'aligned_stack.sav'
RESTORE,'stack.sav'
stack2=stack
stack=0
 l=size(stack2,/dimensions)
 help,stack2
 ncols=l(0)
 nrows=l(1)
 npix=l(2)
 openw,12,'allpixels_sats.dat'
!P.MULTI=[0,3,2]
 for icol=0,ncols-1,1 do begin
     for irow=0,nrows-1,1 do begin
         serie=reform(stack2(icol,irow,*))
	 if (max(serie) gt 53000) then stop
         radius=sqrt((icol-174.5)^2+(irow-261.5)^2)
         moms=moment(serie,/double)
         moms(0)=median(serie)
         printf,format='(5(f15.4,1x),i5,1x,i5)',12,moms,radius,icol,irow
         endfor
     print,icol
     endfor
 close,12
 file='allpixels_sats.dat
 data=get_data(file)
 means=reform(data(0,*))
 vars=reform(data(1,*))
 skew=reform(data(2,*))
 curt=reform(data(3,*))
 rad=reform(data(4,*))
 icol=reform(data(5,*))
 irow=reform(data(6,*))
!P.THICK=2
!X.THICK=2
!Y.THICK=2
!P.charsize=2
!P.charthick=2
 !P.MULTI=[0,1,1]
 plot_oo,means,vars,xtitle='Moment 0',ytitle='Variance',charsize=2,psym=3
 !P.MULTI=[0,2,2]
 plot_oo,means,vars,xtitle='Moment 0',ytitle='Variance',charsize=2,psym=3
 plot_oo,means,skew,xtitle='Moment 0',ytitle='Skewness',charsize=2,psym=3
 plot_oo,means,curt,xtitle='Moment 0',ytitle='Curtosis',charsize=2,psym=3
 !P.MULTI=[0,1,1]
 plot_oo,means,vars,xtitle='Moment 0',ytitle='Variance',charsize=2,psym=3,title='On BS'
 idx=where(rad lt 105 and icol gt 223)
 oplot,means(idx),vars(idx),psym=7,color=fsc_color('red')
 !P.MULTI=[0,1,1]
 plot_oo,means,vars,xtitle='Moment 0',ytitle='Variance',charsize=2,psym=3,title='Sky'
 idx=where(rad gt 115 )
 oplot,means(idx),vars(idx),psym=7,color=fsc_color('red')
 !P.MULTI=[0,1,1]
 plot_oo,means,vars,xtitle='Moment 0',ytitle='Variance',charsize=2,psym=3,title='On disc'
 idx=where(rad lt 106 )
 oplot,means(idx),vars(idx),psym=7,color=fsc_color('red')
 !P.MULTI=[0,1,1]
 plot_oo,means,vars,xtitle='Moment 0',ytitle='Variance',charsize=2,psym=3,title='Lunar rim excluded'
 idx=where(rad lt 106 or rad gt 109 )
 oplot,means(idx),vars(idx),psym=7,color=fsc_color('red')
 !P.MULTI=[0,1,1]
 plot_oo,means,vars,xtitle='Moment 0',ytitle='Variance',charsize=2,psym=3,title='Only Lunar rim'
 idx=where(rad ge 106 and rad le 109 )
 oplot,means(idx),vars(idx),psym=7,color=fsc_color('red')
; regress on those data on-disc excluding rim zone and above 3000
 !P.MULTI=[0,1,1]
 idx=where(rad lt 105 and means gt 3000)
 plot_oo,means,vars,xtitle='Moment 0',ytitle='Variance',charsize=2,psym=3,title='Only BS off-rim'
 oplot,means(idx),vars(idx),psym=7,color=fsc_color('red')
 x=alog10(means(idx))
 y=alog10(vars(idx))
res=linfit(x,y,/double,yfit=yhat,sigma=sigs)
print,'intercept and slope of log vs log plot, linfit:',res
 oplot,10^(x),10^(yhat),color=fsc_color('green'),thick=2
res2=ladfit(x,y,/double)
print,'intercept and slope of log vs log plot, ladfit:',res2
res3=linfit(10^x,10^y,/double,yfit=yhat,sigma=sigs)
print,'intercept and slope of lin vs lin plot, linfit:',res3
print,'mean(varians/mean) for selected points in lin values: ',mean(vars(idx)/means(idx))
print,'median(varians/mean) for selected points in lin values: ',median(vars(idx)/means(idx))
 oplot,10^(x),10^(res2(0)+res2(1)*x),color=fsc_color('blue'),thick=2
; plot histogram of vars/means
histo,vars(idx)/means(idx),0,30,0.2
print,'slopes: ',res(1),' +/- ',sigs(1),' and ',res2(1)
; select some points for later inspection in images
idx=where(vars gt 100.*means)
openw,33,'cols_rows.dat'
for i=0,n_elements(idx)-1,1 do begin
printf,33,icol(idx(i)),irow(idx(i))
endfor
close,33
 end

