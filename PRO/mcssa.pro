;+
;===================================================================================
;                               MCSSA
;===================================================================================
;
; PURPOSE:
; -------
;       Singular spectrum analysis of a time series with testing for red-noise
;       null hypothesis.
;
; CALLING SEQUENCE:
; ----------------
;       ssa, data, wlen, var, trace, teof , tpc, rc
;
; INPUTS:
; ------
;       data     : input time series
;       wlen     : window length
;
; OUTPUTS:
; -------
;       var      : variances
;       teof     : eof's
;       rc       : reconstructed components
;       var0_u   : upper confidence limit of monte-carlo based null-hypothesis variances
;       var0_l   : lower confidence limit of monte-carlo based null-hypothesis variances
;
; KEYWORD PARAMETERS:
; ------------------
;       double     : perform calc. in double precision
;       nderiv     : # of derived components
;       sigcomp    : RC components defined as signal
;       siglev     : significance levels of null-hypothesis variances
;       nmc        : #of Monte Carlo simulations
;       rho1       : estimated lag-1 autocorrelation of noise
;       whitenoise : when set, forces white noise
;       assoc_freq : A frequency associated to each eof
;       teof_fit   : The corresponding fittet sinosoidal
;
; COMMON BLOCKS:
; -------------
;       None.
;
; NOTES:
; -----
;       None.
;
; EXAMPLE:
; -------
;       None.
;
; AUTHOR:
; ------
;       Torben Schmith,  6/6-2005.
;
; REVISIONS:
; ---------
;       Torben Schmith,  24/10-2005.
;
;===================================================================================
;-

pro mcssa, data, wlen, var, trace, teof , tpc, rc, var0_u, var0_l, $
           nderiv = nderiv, double = double, sigcomp = sigcomp, $
           siglev = siglev, nmc = nmc, rho1 = rho1, whitenoise = whitenoise, $
           assoc_freq = assoc_freq, teof_fit = teof_fit


; determine dimensions of input data etc.

nobs    = n_elements( data )

; make anomalies

if keyword_set( double ) then xanom = dblarr( nobs)                 $
                         else xanom = fltarr( nobs)

xanom = data - mean( data , double = double )


; compute covariance matrix (Vautard and Ghil)

lag = indgen( wlen)
acovar = a_correlate( xanom, lag, /covariance, double = double )
acovar = acovar * float( nobs ) / float(nobs-lag)

if keyword_set( double ) then xx = dblarr( wlen, wlen)                 $
                         else xx = fltarr( wlen, wlen)

for i = 1, wlen do begin
   for j = 1, wlen do begin
      xx[i-1, j-1] = acovar[ abs(i-j) ]
   endfor
endfor


; eigenvalues and -vectors

eigenvec = xx

trired, eigenvec, diag, ofdiag, double = double

triql, diag, ofdiag, eigenvec, double = double

isort = reverse( sort( diag) )
diag = diag[ isort ]
eigenvec = eigenvec[*,isort]

var  = diag( 0:nderiv-1 ) / ( nobs - 1 )
trace = total( diag)   / ( nobs - 1 )
teof = eigenvec (*,0:nderiv-1)
;***teof = teof * rebin( transpose( sqrt( var ) ), wlen, nderiv)


; calculate scores

if keyword_set( double ) then tpc = dblarr( nderiv, nobs-wlen+1 )                 $
                         else tpc = fltarr( nderiv, nobs-wlen+1 )

for iobs = 1, nobs-wlen+1 do begin
   tpc[*,iobs-1] = xanom[iobs-1:iobs+wlen-2] ## transpose( teof )
endfor


; reconstructed components

if keyword_set( double ) then rc = dblarr( nderiv, nobs)                 $
                         else rc = fltarr( nderiv, nobs)

for ideriv = 1, nderiv do begin

   iobs = 1
   rc[ideriv-1,iobs-1] = tpc[ideriv-1, iobs-1 ] * teof[iobs-1,ideriv-1] / float( iobs )

   for iobs = 2, wlen-1 do begin
      rc[ideriv-1,iobs-1] = total( reverse( tpc[ideriv-1, 0: iobs-1 ], 2 ) * teof[0:iobs-1,ideriv-1] ) / float( iobs )
   endfor

   for iobs = wlen, nobs-wlen+1 do begin
      rc[ideriv-1,iobs-1] = total( reverse( tpc[ideriv-1, iobs-wlen:iobs-1 ], 2 ) * teof[*,ideriv-1] ) / float( wlen )
   endfor

   for iobs = nobs-wlen+2, nobs-1 do begin
      rc[ideriv-1,iobs-1] = total(  reverse( tpc[ideriv-1, iobs-wlen:nobs-wlen ], 2 )  $
                                   * teof[iobs-nobs+wlen-1:wlen-1,ideriv-1] )              $
                          / float( nobs-iobs+1 )
   rc[ideriv-1,nobs-1] = tpc[ideriv-1, nobs-wlen ] * teof[wlen-1,ideriv-1]

   endfor

endfor


; associated frequencies

assoc_freq = fltarr( nderiv )
teof_fit = fltarr( wlen, nderiv )

for ideriv = 1, nderiv do begin
   corr_sq = fltarr( wlen/2, wlen )
   for ifreq = 1, wlen / 2 do begin
      for i0 = 0, wlen-1 do begin
         corr_sq[ifreq-1, i0] = correlate( teof[*,ideriv-1] ,                      $
                                     sin( 2. * !pi * float(ifreq) / float(wlen)  $
                                            * ( findgen(wlen) - float(i0) ) ) ) ^2
      endfor
   endfor

   res = max( corr_sq, index1 )
   index = array_indices( corr_sq, index1 )
   assoc_freq[ideriv-1] = float( index[0]+1 ) / float( wlen )
   teof_fit[*,ideriv-1] = sin( 2. * !pi * assoc_freq[ideriv-1]  $
                                            * ( findgen(wlen) - float(index[1]) ) )
endfor


; *** surrogate data

if n_elements( sigcomp ) eq 0 then begin
   signal = replicate( 0., nobs)
   noise = xanom
endif else begin
   signal = total( rc[ sigcomp-1,*], 1 )
   noise = xanom - signal
endelse

if keyword_set( whitenoise ) then begin
   rho1 = 0.
endif else begin
   rho1 = a_correlate( noise, 1, double = double )
   rho1 = rho1[0]
endelse

noise_std = stddev( noise , double = double )
sigma = sqrt( 1. - rho1^2 ) * noise_std

if n_elements( nmc ) eq 0 then nmc = 1000

ninit = 25


;*** rowno = intarr(wlen, wlen )
;*** colno = intarr(wlen, wlen )

;*** for i = 1, wlen do begin
;***    for j = 1, wlen do begin
;***       colno[i-1, j-1] = i
;***       rowno[i-1, j-1] = j
;***    endfor
;*** endfor


if keyword_set( double ) then var_mc = dblarr( nmc, nderiv ) else var_mc = fltarr( nmc, nderiv )

for imc = 1L, nmc do begin

   if imc mod 100 eq 0 then print, 'MC realisations: ' ,  imc

   if keyword_set( double ) then noise_mc = dblarr( ninit + nobs ) else noise_mc = fltarr( ninit + nobs )

   noise_mc[0] = randomn(seed,1, double = double)
   for i = 2, ninit + nobs do begin
      noise_mc[i-1] = rho1 * noise_mc[i-2] + sigma * randomn(seed,1, double = double)
   endfor

   noise_mc = noise_mc[ninit:*]
   x_mc = signal + noise_mc
   x_mc = x_mc - mean( x_mc, double = double )

   acovar_mc = a_correlate( x_mc, lag, /covariance, double = double )
   acovar_mc = acovar_mc * float( nobs ) / float(nobs-lag)

   if keyword_set( double ) then xx_mc = dblarr( wlen, wlen)                 $
                            else xx_mc = fltarr( wlen, wlen)

;***   for i = 0, wlen - 1 do begin
;***      isel = where( abs( rowno + colno ) ) eq i
;***      xx_mc[ isel ] = acovar_mc[ i ]
;***   endfor
   
   
   for i = 1, wlen do begin
      for j = 1, wlen do begin
         xx_mc[i-1, j-1] = acovar_mc[ abs(i-j) ]
      endfor
   endfor

; project onto original eof's

   for ideriv = 1, nderiv do begin
      var_mc[imc-1,ideriv-1] = reform( teof[*,ideriv-1] ## xx_mc ## transpose( teof[*,ideriv-1] ) ) / float( nobs - 1 )
   endfor
endfor


if n_elements( siglev ) eq 0 then siglev = 0.95

if keyword_set( double ) then begin
   var0_u = dblarr( nderiv)
   var0_l = dblarr( nderiv)
endif else begin
   var0_u = fltarr( nderiv)
   var0_l = fltarr( nderiv)
endelse

for ideriv = 1, nderiv do begin
   var0_u[ideriv-1] = percentiles( var_mc[*,ideriv-1], value = (1. + siglev)/2. )
   var0_l[ideriv-1] = percentiles( var_mc[*,ideriv-1], value = (1. - siglev)/2. )
endfor

end
