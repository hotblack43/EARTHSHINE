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
 ; shift to origin
 kernel=shift(kernel,n/2.,n/2.)
 return
 end
FUNCTION countnegatives,a
 common stuff,FFTideal,observed,ideal,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
;
;	An image FFT is divided bythe PSF FFT and forward FTd, 
;	then numbe rof negative values is counted
;
 peakval=a(0)
 widthfactor=a(1)
get_kernel,PSF,peakval,widthfactor
ratio=FFT(observed-100,-1,/double)/FFT(PSF,-1,/double)
result=double(FFT(ratio,1,/double))
surface,result,charsize=2
;tvscl,[bytscl(alog(PSF)),bytscl(result)]
;plot,result(*,256),/ylog
negs=n_elements(where(result le 0.0))
print,a,negs
return,negs
end

PRO go_do_powell,start_parms
 ; Find best parametrs using POWELL method
 ; and the counting of negativesNx=n
 xi=[[0,1],[1,0]]
 ftol=1.e-8
 POWELL,start_parms,xi,ftol,fmin,'countnegatives'
 return
 end

 CPU, TPOOL_MIN_ELTS=10000, TPOOL_NTHREADS=2
 common stuff,FFTideal,observed,ideal,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
 common flags,iflag,iflag2
 iflag=-911
 ; read in the image to be corrected
 ; get the observed file names
 path='OUTPUT/IDEAL/'
 idealnames=file_search(path+'ideal_*.fit',count=n0)
 for ifile=0,n0-1,1 do begin
 ideal=readfits(idealnames(ifile),header)
 l=size(ideal,/dimensions)
 if (l(0) ne l(1)) then stop
 n=l(0)
 tstr='WholeSkyPOISSON'
; set up the arrayfor the PSF
 r=dblarr(n,n)
 rr=dblarr(n,n)
 for i=0,n-1,1 do begin
     for j=0,n-1,1 do begin
         r(i,j)=sqrt((i-n/2.)^2+(j-n/2.)^2)
         endfor
     endfor
 ;...................................................................
 ; set up the input to the solver
 start_parms=[5000.0d0 ,    .1d0] ; these are p, and w starting guesses
get_kernel,PSF,start_parms(0),start_parms(1)
; construct the observed image
observed=fft(ffT(ideal,-1,/double)*fft(PSF,-1,/double),1,/double)
;////////////////////////////////////////////
; stuff for POWELL
go_do_POWELL,start_parms
stop
;////////////////////////////////////////////
 print,'Solutions:'
 print,'p',start_parms(0)
 print,'w:',start_parms(1)
 endfor	; ifile loop
 end
 
