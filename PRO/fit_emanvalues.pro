FUNCTION extinction, X, A
common wave,wave,o3_corr
idx=where(wave eq x)
   extinct = a(0)*(x^a(1))+a(2)*(x^a(3))	;	+a(4)*o3_corr(idx(0))
   RETURN,extinct
END

;------------------------ Fit the mean values of UBV etc---------------
!P.CHARSIZE=2
common wave,wave,o3_corr
o3_corr=[.016d0,0.0d0,0.0d0,0.00d0,.025d0,.030d0,.039d0]	; abs per airamss at the filters bands due to O3
wave=[3464.,4015.,4227.,4476.,5395.,5488.,5807.]
wave=wave/10000.0d0		; converting to microns
fita=[1,0,1,0]       ; switches for parameters to optimize
a=fita*0.0
maxiter=1000
x=wave

;....
	parinfo=replicate({value:0.D,fixed:0,limited:[0,0],limits:[0.D,0]},n_elements(a))
; setting limits on bRC
	parinfo(0).limited[0]=1
	parinfo(0).limits[0]=0.0d0
; setting limits on Rayleigh power
	parinfo(1).limited[0]=0
	parinfo(1).limited[1]=0
	parinfo(1).limits[0]=-23.0d0
	parinfo(1).limits[1]=0.0d0
	parinfo(1).fixed=1
; setting limits on bp
	parinfo(2).limited[0]=1
	parinfo(2).limits[0]=0.0d0
; setting limits on aerosol power
	parinfo(3).limited[0]=1
	parinfo(3).limited[1]=1
	parinfo(3).limits[0]=-12.0d0
	parinfo(3).limits[1]=30.
	parinfo(3).fixed=1
; setting limits on O3 factor
	;parinfo(4).limited[0]=1
	;parinfo(4).limits[0]=0.0d0
	;parinfo(4).fixed=1
; set start values
    a(0)=0.007
	a(1)=-4.05
	a(2)=0.011
	a(3)=-1.39
	parinfo(*).value=[a]
; fit


; finally fit the model to the mean values of UBV etc
data=get_data('Mean_UB1BB2V1VG.dat')
means=reform(data(*,0))
means=[.611,.317,.262,.213,.130,.130,.118] ; table 4 in Paper II (Burki et al).
errs=reform(data(*,1))
means=double(means)
errs=double(errs)
	parms = MPFITFUN('extinction', X(1:3), means(1:3), errs(1:3), a,yfit=yfit, PARINFO=parinfo, $
		PERROR=sigs,/quiet,maxiter=maxiter,niter=niter)
		a=parms
		!P.MULTI=[0,1,1]
		plot,x,means,psym=4,xtitle='!7k!3 (!7l!3m)',ytitle='k(!7k!3)',xrange=[0.287,0.79],xstyle=1,yrange=[-0.005,0.690],ystyle=1,xminor=5,yminor=4,title='Fig 4 from data in table 4 Burki 95'
		;oploterr,x,means,errs
		waves=indgen(100)/100.*.39+.32
		oplot,waves,a(0)*waves^a(1),thick=3
		oplot,waves,a(2)*waves^a(3),thick=3,linestyle=2
		residuals=means-(a(0)*x^a(1)+a(2)*x^a(3))
		oplot,x,residuals,psym=7
		xyouts,/data,0.45,0.60,strcompress('k Measures (diamonds)'),charsize=1.5
		xyouts,/data,0.45,0.55,strcompress('k!dRC!n = '+strmid(string(a(0)),0,11)+' !7k!3!u'+strmid(string(a(1)),0,11)+'!n  (thick)'),charsize=1.5
		xyouts,/data,0.45,0.50,strcompress('k!dp !n  = '+strmid(string(a(2)),0,12)+' !7k!3!u'+strmid(string(a(3)),0,11)+'!n (dashed)'),charsize=1.5
		xyouts,/data,0.45,0.45,strcompress('k!dO3!n  =  k - k!dRC!n - k!dp !n  (crosses)'),charsize=1.5
		print,format='(a,7(1x,f8.4))','parameters:',parms
		print,format='(a,7(1x,f8.4))','sigmas      :',sigs
		print,format='(a,7(1x,f8.3))','kO3=k-kp-kRC:',residuals
		print,format='(a,7(1x,f8.3))','kO3 from Ruf86',o3_corr
end