;***********************************************************************
; Program demonstrates MCSSA
;
;***********************************************************************
;
; Language: IDL
;
;***********************************************************************
;
; Programmed by: Torben Schmith, 3/8-2005.
;
; Last update by:Torben Schmith, 3/8-2005.
;
;***********************************************************************

; define plotting environment

type = 'ps'

if ( type eq 'x') then begin
  set_plot,'x'
  device, pseudo_color = 8, decomposed = 0
  iwin = 0
  xsize = 600
  ysize = 850
endif

if ( type eq 'ps' ) then begin
  set_plot,'ps'
  device, filename="/ts/tmp/plot.ps",                      $
          xsize = 16., xoffset = 2., ysize = 25., yoffset = 2., $
          /color, bits_per_pixel = 8
endif

nyear    = 500
nyears = indgen( nyear )

ninit = 50


; time series

a1       = 0.
period1  = 80.

a2       = 0.5
period2  = 17.

trend    = 0.

sigma_n    =  0.5
rho_n      =  0.

noise  = fltarr( ninit + nyear )

noise[0]  = 0.
for i = 1, ninit + nyear - 1 do begin
   noise[i] = rho_n * noise[i-1] + sigma_n/(1.-rho_n) * randomn( seed, 1)
endfor

noise = noise[ninit:*]

signal = a1 * cos( 2. * !pi * float( nyears ) / period1 )                          $
  + a2 * cos( 2. * !pi * float( nyears ) / period2 )                          $
  + trend * ( nyears - nyears[nyear/2] ) / float( nyear )

x = signal + noise

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'x'
  iwin = iwin + 1
endif

!p.multi = [0,1,3]

plot, nyears, x, title = 'x', xtitle = '[yr]'
plot, nyears, signal, title = 'signal', xtitle = '[yr]'
plot, nyears, noise, title = 'noise', xtitle = '[yr]'

signature, "T. Schmith", /idldate


; spectrum

freqs    = findgen( nyear/2 ) / float(nyear)

nsmooth = 15

ft = fft( x - mean( x ) )
peri = abs( ft[0:nyear/2] )^2
spec = smooth( peri , nsmooth, /edge_truncate )

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'spec'
  iwin = iwin + 1
endif

!p.multi = [0,1,1]

plot, freqs[1:*], spec[1:*], /xlog, /ylog, xtitle = 'frequency [yr!e-1!n]', title = 'Spectrum'

signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate


; ssa/mcssa

wlen = 100
nderiv = 100

error = 0.
rho1 = 0.
teof_fit = fltarr( wlen, nderiv )


ssa, x,wlen, var_ssa, trace_ssa, teof_ssa , tpc_ssa, rc_ssa, nderiv = nderiv, ghil_mo = error

sigcomp = [ 1,2]
nmc = 1000

mcssa, x,wlen, var_mcssa, trace_mcssa, teof_mcssa , tpc_mcssa, rc_mcssa,       $
       var0_u, var0_l, nderiv = nderiv, siglev = .99,                          $
       nmc = nmc, rho1 = rho1, assoc_freq = assoc_freq, teof_fit = teof_fit, $
       sigcomp = sigcomp


print, 'rho: ' , rho1

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'ssa spec'
  iwin = iwin + 1
endif

!p.multi = [0,1,4]

ymin = min( [var0_l, var_ssa - error ] / trace_ssa )
ymax = max( [var0_u, var_ssa + error ] / trace_ssa )

eigrank = indgen(nderiv)+1
plot, eigrank, var_ssa / trace_ssa, title = 'SSA spectrum',          $
     /ylog, psym = 4, yrange = [ymin, ymax]
errplot, eigrank, ( var_ssa - 2*error ) / trace_ssa, ( var_ssa + 2*error ) / trace_ssa

plot, eigrank, var_mcssa / trace_mcssa, title = 'MCSSA spectrum',          $
     /ylog, psym = 4, yrange = [ymin, ymax]
;***if n_elements( sigcomp )ne 0 then oplot, eigrank[sigcomp-1], var_mcssa[sigcomp-1] / trace_mcssa, psym = 4, thick = 5
isel = where( var_mcssa ge var0_u )
if isel[0] ne -1 then oplot, eigrank[isel], var_mcssa[isel] / trace_mcssa, psym = 4, thick = 5
;***oplot, indgen(nderiv)+1,  var0_u / trace_mcssa
;***oplot, indgen(nderiv)+1,  var0_l / trace_mcssa
errplot, eigrank,  var0_l / trace_mcssa, var0_u / trace_mcssa

plot, eigrank, assoc_freq, xtitle = 'rank', ytitle = 'associated frequency', psym = 4

plot, assoc_freq,  var_mcssa / trace_mcssa, title = 'MCSSA spectrum',          $
     /ylog, psym = 4, yrange = [ymin, ymax]
isel = where( var_mcssa ge var0_u )
if isel[0] ne -1 then oplot, assoc_freq[isel], var_mcssa[isel] / trace_mcssa, psym = 4, thick = 5
errplot, assoc_freq,  var0_l / trace_mcssa, var0_u / trace_mcssa


signature, "T. Schmith", /idldate


for ideriv = 1, nderiv do begin

   if ideriv mod 5 eq 1 then begin
      if ideriv ne 1 then begin
         signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate
      endif

      if ( type eq 'x') then begin
         window, iwin, xsize = xsize, ysize = ysize, title =  't-eof'
         iwin = iwin + 1
      endif

      !p.multi = [0, 1, 5 ]
   endif

   if ideriv eq nderiv then begin
      signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate
   endif

   plot, teof_mcssa[*,ideriv-1], title = 't-eof no.: ' + string( ideriv, format = '(i3)' ) + ' (MCSSA)', yrange = [-1.,1]
   oplot, teof_fit[*,ideriv-1], linestyle = 2
   oplot, !x.crange, [0., 0.], linestyle = 1

endfor

signature, "T. Schmith", /idldate


; reconstruction

if n_elements( sigcomp ) ne 0 then begin
   recon = total( rc_mcssa[sigcomp-1,*], 1 )
   ftr   = fft( recon - mean( recon ) )
   specr = smooth( abs( ftr[0:nyear/2-1] ) ^2, nsmooth, /edge_truncate )

   if ( type eq 'x') then begin
     window, iwin, xsize = xsize, ysize = ysize, title =  'rc'
     iwin = iwin + 1
   endif

   !p.multi = [0,1,2]

   plot, nyears, x , title = 'ssa recon (sigcomp)',                                                 $
        xtitle = '[yr]'
   oplot, nyears, recon, thick = 5

   plot, freqs[1:*], specr[1:*], title = 'Spectrum (whole signal)',                        $
         xtitle = '[yr!e-1!n]',  /xlog,  /ylog
   oplot, freqs[1:*], spec[1:*], linestyle = 2
endif

;exit

if ( type eq 'ps' ) then begin
  device, /close
endif

end
