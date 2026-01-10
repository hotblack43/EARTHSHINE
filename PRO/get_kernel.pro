 PRO get_kernel,kernel,peakval,widthfactor
 common stuff,FFTideal,observed,ideal,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
 common flags,iflag,iflag2
 data=get_data('TOMSTONE/nozeros_ROLO_765nm_Vega_psf.dat')
 x=reform(data(0,*))
 y=reform(data(1,*))
 kernel=dblarr(n,n)
 fillval=min(y(where(y gt 0)))
 kernel=INTERPOL(y,x,r*widthfactor)
 kdx=(where(kernel lt fillval))
 if (kdx(0) ne -1) then kernel(kdx)=fillval
 ;put a variable-height spike in the centre
 kernel(n/2.,n/2.)=kernel(n/2.,n/2.)*peakval
 ; and normalize
 kernel=kernel/total(kernel)*float(n*n)
 ;surface,kernel
 return
 end
