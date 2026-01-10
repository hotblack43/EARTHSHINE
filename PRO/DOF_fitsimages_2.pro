array=alog(get_data('problem1.dat'))
;
l=size(array,/dimensions)
array=array(0:l(0)-4,*)
l=size(array,/dimensions)
   ;Remove the mean from each variable.
   m = l(0)    ; number of variables
   n = l(1)   ; number of observations
   means = TOTAL(array, 2)/n
   array = array - REBIN(means, m, n)

   ;Compute derived variables based upon the principal components.
   result = PCOMP(array, COEFFICIENTS = coefficients, $
      EIGENVALUES=eigenvalues, VARIANCES=variances, /COVARIANCE)
   PRINT, 'Result: '
   PRINT, result, FORMAT = '(4(F8.2))'
   PRINT
   PRINT, 'Coefficients: '
   FOR mode=0,3 DO PRINT, $
      mode+1, coefficients[*,mode], $
      FORMAT='("Mode#",I1,4(F10.4))'
   eigenvectors = coefficients/REBIN(eigenvalues, m, m)
   PRINT
   PRINT, 'Eigenvectors: '
   FOR mode=0,3 DO PRINT, $
      mode+1, eigenvectors[*,mode],$
      FORMAT='("Mode#",I1,4(F10.4))'
   array_reconstruct = result ## eigenvectors
   PRINT
   PRINT, 'Reconstruction error: ', $
      TOTAL((array_reconstruct - array)^2)
   PRINT
   PRINT, 'Energy conservation: ', TOTAL(array^2), $
      TOTAL(eigenvalues)*(n-1)
   PRINT
   PRINT, '     Mode   Eigenvalue  PercentVariance'
   FOR mode=0,3 DO PRINT, $
      mode+1, eigenvalues[mode], variances[mode]*100

;
!P.MULTI=[0,2,2]
   FOR mode=0,3 DO  begin
	surface,reform(eigenvectors(*,mode),16,16)
 endfor

END
