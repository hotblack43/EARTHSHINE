function ssa,                    $
       timeseries,               $
       m=m,                      $
       kvec=kvec,                $
       toeplitz=toeplitz,        $
       surro=surro,              $
       seed=seed,                $
       eigenvalues=eigenvalues,  $
       xmodes=xmodes,            $
       a=a                      

;+************************************************************* 
;               Singular spectrum analysis.
;
;    Bo Christiansen, Danish Meteorological Institute, 2004.
;
; See, e.g.,
;  M. Ghil et al.,
;  Advanced spectral methods for climatic time series 
;  Rev. Geophys., 40(1), pp. 3.1–3.41, doi: 10.1029/2000RG000092, 2002.
; 
;  Input:
;   timeseries: 1-dim. array to be analysed.
;   m         : The embedding dimension (default 2).
;   kvec      : 1-dim array of modes used in the reconstruction (default indgen(m)).
;   toeplitz  : If 1 (default 0) the covariance matrix is supposed to have Toeplitz form.
;   surro     : If 1 (default 0) the modes are randomly shifted to create surrogate time-series.
;   seed      : Seed to random number generator (default 2.). Only used if surro=1.
;
;  Output:
;   The function returns the reconstructed (or surrogate if surro=1) time-series.
;   eigenvalues : The m eigenvalues.
;   xmodes      : An m x m matrix (mode,lag) containing the modes.
;   a           : An (N-m+1) x m matrix (time,mode) containing the principal components. N is the # of elements in timeseries.
;
;-********************************************************* 

 if n_elements(m) EQ 0 then m=2
 if n_elements(kvec) EQ 0 then kvec=indgen(m)
 if n_elements(toeplitz) EQ 0 then toeplitz=0
 if n_elements(surro) EQ 0 then surro=0
 if n_elements(seed) EQ 0 then seed=2.

 n=n_elements(timeseries)
 Nm=N-M+1

 if (toeplitz EQ 0) then begin
  print,'trajectory'
  d=fltarr(NM,M)
  for i=0,NM-1 do d[i,*]=timeseries[i:i+M-1]
  c=transpose(d)#d/Nm
 
  svdc,c,w,ymodes,xmodes,/double
  eigenvalues=w^2  ;/total(w^2)
 endif else begin
  print,'toeplitz'
  ca=fltarr(M)
  for q=0,M-1 do ca[q]=total(timeseries[0:N-q-1]*timeseries[q:N-1])/(N-q)
 
  c=fltarr(M,M)
  for ii=0,M-1 do for jj=0,M-1 do c[ii,jj]=ca[abs(ii-jj)]
 
  trired,c,d,e,/double
  triql,d,e,c,/double
  eigenvalues=d(reverse(sort(d)))
  xmodes=dblarr(M,M)
  xmodes[*,*]=transpose(c[*,reverse(sort(d))])
endelse 

 a=fltarr(Nm,M)
 for k=0,M-1 do for itime=0,N-M do a[itime,k]=total(timeseries[itime:itime+M-1]*xmodes[k,*])

 ;if scramble then for k=0,M-1 do a[*,k]=scramble_phases(a[*,k],seed=seed)
 if surro then for k=0,M-1 do a[*,k]=shift(reform(a[*,k]),ceil(randomu(seed,1)*Nm))

 kmax=n_elements(kvec)

 rk=fltarr(n)
 for itime=M-1,NM-1 do begin
  rm=0
  for k=0,kmax-1 do for j=0,M-1 do rm =rm + a[itime-j,kvec[k]]*xmodes[kvec[k],j]
  rk[itime]=rm/M
 endfor
 for itime=0,M-2 do begin
  rm=0
  for k=0,kmax-1 do for j=0,itime-1 do rm =rm + a[itime-j,kvec[k]]*xmodes[kvec[k],j]
  rk[itime]=rm/(itime+1)
 endfor
 for itime=NM,N-1 do begin
  rm=0
  for k=0,kmax-1 do for j=itime-N+M,M-1 do rm =rm + a[itime-j,kvec[k]]*xmodes[kvec[k],j]
  rk[itime]=rm/(N-itime)
 endfor

 return, rk
end
