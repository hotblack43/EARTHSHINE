RESTORE,'aligned_stack.sav'
 l=size(stack2,/dimensions)
 help,stack2
 stack2=double(stack2)
 ncols=l(0)
 nrows=l(1)
 npix=l(2)
	help,ncols,nrows,npix
 openw,12,'allpixels_sats.dat'
 for icol=0,ncols-1,1 do begin
     for irow=0,nrows-1,1 do begin
         serie=reform(stack2(icol,irow,*))
         moms=moment(serie,/double)
         mn=mean(serie)
         std=stddev(serie)
         pct=(mn-moms(0))/moms(0)*100.0
	if (pct gt 1) then stop
         printf,format='(5(f15.4,1x))',12,moms,mn
         endfor
     print,icol
     endfor
 close,12
 file='allpixels_sats.dat
 data=double(get_data(file))
 means=reform(data(0,*))
 vars=reform(data(1,*))
 skew=reform(data(2,*))
 curt=reform(data(3,*))
 mn=reform(data(4,*))
 !P.MULTI=[0,2,2]
 plot_oo,means,vars,xtitle='Moment 0',ytitle='Variance',charsize=2,psym=3
 plot_oo,means,skew,xtitle='Moment 0',ytitle='Skewness',charsize=2,psym=3
 plot_oo,means,curt,xtitle='Moment 0',ytitle='Curtosis',charsize=2,psym=3
 plot_oo,means,mn,xtitle='Moment 0',ytitle='sqrt(mean)',charsize=2,psym=3
 end


