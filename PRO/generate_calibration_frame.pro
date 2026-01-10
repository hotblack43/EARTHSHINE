im=readfits('OUTPUT/IDEAL/ideal_LunarImg_0471.fit')
 l=size(im,/dimensions)
 ; scale to reasonable CCD count
 maxval=max(im)
 im=fix(im/maxval*40000.)
 ; block lower half
 factor=1.0
 im(*,l(1)/2:l(1)-1)=fix(im(*,l(1)/2:l(1)-1)/factor)
 ; apply Poisson stats
 for i=0,l(0)-1,1 do begin
     for j=0,l(1)-1,1 do begin
         value=im(i,j)
         if (im(i,j) gt 0) then im(i,j)=randomn(seed,poisson=value)
         endfor
     endfor
 ; just one col
 icol=l(0)/2.
 xhi=indgen(500-350+1)
 high=reform(im(icol,350:500))
 res1=linfit(xhi,high,/double,yfit=yhat1)
 high_res=high-(res1(1)*xhi)
 ;
 xlo=indgen(650-580+1)
 low=reform(im(icol,580:650))
 res2=linfit(xlo,low,/double,yfit=yhat2)
 low_res=low-(res2(1)*xlo)
 plot_io,xhi,high_res,yrange=[1,1e5]
 oplot,xhi,yhat1
 oplot,xlo,yhat2
 oplot,xlo,low_res
 sighi=stddev(high_res)/sqrt(n_elements(high_res))
 siglo=stddev(low_res)/sqrt(n_elements(low_res))
 print,mean(high_res),sighi
 print,mean(low_res),siglo
 print,'Ratio :',mean(high_res)/mean(low_res),' +/- ',sqrt(sighi^2+siglo^2)
 oplot,xlo,low_res*mean(high_res)/mean(low_res),psym=7
 end
