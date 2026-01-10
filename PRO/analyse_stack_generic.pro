; get the right dark frame
darkframe=readfits('median_dark_smoothed.fit')
;RESTORE,'aligned_stack.sav'
RESTORE,'stack.sav'
stack2=stack
stack=0
 l=size(stack2,/dimensions)
 help,stack2
 ncols=l(0)
 nrows=l(1)
 npix=l(2)
 ; select slices for uniformity of some statistics
 slice_mn=FLTARR(NPIX)
 slice_std=FLTARR(NPIX)
 ratio=fltarr(npix)
 for i=0,npix-1,1 do begin
 	slice_mn(i)=mean(stack2(*,*,i))
 	slice_std(i)=stddev(stack2(*,*,i))
 	ratio(i)=slice_std(i)/slice_mn(i)
 endfor
 select_pix=where((slice_mn gt 17000 and slice_mn lt 17620) and (slice_std gt 5500) and (ratio gt 0.349 and ratio lt 0.355))
 plot,slice_mn(select_pix),slice_std(select_pix),psym=7,xstyle=1,ystyle=1
 stack2=stack2(*,*,select_pix)
  l=size(stack2,/dimensions)
 help,stack2
 ncols=l(0)
 nrows=l(1)
 npix=l(2)
 openw,12,'allpixels_sats.dat'
!P.MULTI=[0,3,2]
 for icol=0,ncols-1,1 do begin
     for irow=0,nrows-1,1 do begin
    ;darkframe=darkframe*0.0
         serie=reform(stack2(icol,irow,*))-darkframe(icol,irow)
	 if (max(serie) gt 53000) then stop
         moms=moment(serie,/double)
         moms(0)=median(serie)
         printf,format='(4(f15.4,1x),i5,1x,i5)',12,moms,icol,irow
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
 icol=reform(data(4,*))
 irow=reform(data(5,*))
!P.THICK=2
!X.THICK=2
!Y.THICK=2
!P.charsize=2
!P.charthick=2
 !P.MULTI=[0,1,1]
 plot_oo,means,vars,xtitle='Mean',ytitle='Variance',charsize=2,psym=3
res=linfit(means,vars,/double,yfit=yhat,sigma=sigs)
oplot,means,yhat,color=fsc_color('red'),psym=3
print,'linfit intercept and slope of lin lin plot:',res
oplot,means,means
res=ladfit(means,vars,/double)
print,'ladfit intercept and slope of lin lin plot:',res
z=vars/means
print,'C=<vars/mn> :',mean(z)
res=linfit(alog10(means),alog10(vars),/double,yfit=yhat,sigma=sigs)
oplot,means,10^yhat,color=fsc_color('blue'),psym=3
print,'anti-log of linfit on log-log :',10^res
 end

