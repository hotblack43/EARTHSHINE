data=get_data('SEMdmi.data')
angle=reform(data(0,*))
data(1,*)=data(1,*)-min(data(1,*))
idx=sort(data(1,*))
data=data(*,idx)
;data(0,*)=1
;
;kdx=where(data(1,*) gt 150 and data(1,*) lt 160)
;array=data(*,kdx)
array=data
Result = PCOMP( array , COEFFICIENTS=coeffs, /COVARIANCE, /DOUBLE, EIGENVALUES=eigenv, NVARIABLES=nvars, /STANDARDIZE, VARIANCES=vars)
help
end
