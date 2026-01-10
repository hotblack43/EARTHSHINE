PRO pcomp_doc

   ;Define an array with 4 variables and 20 observations.
   array = [[19.5, 43.1, 29.1, 11.9], $
            [24.7, 49.8, 28.2, 22.8], $
            [30.7, 51.9, 37.0, 18.7], $
            [29.8, 54.3, 31.1, 20.1], $
            [19.1, 42.2, 30.9, 12.9], $
            [25.6, 53.9, 23.7, 21.7], $
            [31.4, 58.5, 27.6, 27.1], $
            [27.9, 52.1, 30.6, 25.4], $
            [22.1, 49.9, 23.2, 21.3], $
            [25.5, 53.5, 24.8, 19.3], $
            [31.1, 56.6, 30.0, 25.4], $
            [30.4, 56.7, 28.3, 27.2], $
            [18.7, 46.5, 23.0, 11.7], $
            [19.7, 44.2, 28.6, 17.8], $
            [14.6, 42.7, 21.3, 12.8], $
            [29.5, 54.4, 30.1, 23.9], $
            [27.7, 55.3, 25.7, 22.6], $
            [30.2, 58.6, 24.6, 25.4], $
            [22.7, 48.2, 27.1, 14.8], $
            [25.2, 51.0, 27.5, 21.1]]

   ;Remove the mean from each variable.
   m = 4    ; number of variables
   n = 20   ; number of observations
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

END
