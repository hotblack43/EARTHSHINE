;***********************************************************************
; Program demonstrates SSA
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
  device, filename="/tmp/plot.ps",                      $
          xsize = 16., xoffset = 2., ysize = 25., yoffset = 2., $
          /color, bits_per_pixel = 8
endif

nyear    = 500
nyears = indgen( nyear )


; time series

a1       = 0.3
period1  = 80.

a2       = 0.0
period2  = 17.

trend    = 1.

sig_eps  = .5

x = a1 * cos( 2. * !pi * float( nyears ) / period1 )                          $
  + a2 * cos( 2. * !pi * float( nyears ) / period2 )                          $
  + trend * ( nyears - nyears[nyear/2] ) / float( nyear )                     $
  + sig_eps * randomn( seed, nyear )

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'x'
  iwin = iwin + 1
endif

!p.multi = [0,1,1]

plot, nyears, x, title = 'x',                                                 $
     xtitle = '[yr]'

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


; ssa

wlen = 150
nderiv = 20

error = 0.

ssa, x,wlen, var, trace, teof , tpc, rc, nderiv = nderiv, ghil_mo = error

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'spec'
  iwin = iwin + 1
endif

!p.multi = [0,1,1]

plot, indgen(nderiv)+1, var / trace, title = 'SSA spectrum', /ylog, psym = 4
oploterr, indgen(nderiv)+1, var / trace, error / trace

signature, "T. Schmith", /idldate


if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  't-eof-pc'
  iwin = iwin + 1
endif

!p.multi = [0,2,min( [8, nderiv] )]

for ideriv = 1, min( [8, nderiv] ) do begin
   plot, teof[*,ideriv-1], title = 't-eof no.: ' + string( ideriv, format = '(i3)' )
   oplot, !x.crange, [0., 0.], linestyle = 1

   plot, tpc[ideriv-1,*], title = 't-pc no.: ' + string( ideriv, format = '(i3)' )
   oplot, !x.crange, [0., 0.], linestyle = 1

endfor

signature, "T. Schmith", /idldate


; reconstruction

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'rc'
  iwin = iwin + 1
endif

!p.multi = [0,1,3]

plot, nyears, x , title = 'ssa recon (1)',                                                 $
     xtitle = '[yr]'
oplot, rc[0,*], thick = 3

plot, nyears, x , title = 'ssa recon (1-3)',                                                 $
     xtitle = '[yr]'
oplot, total( rc[0:2,*], 1 ), thick = 3

plot, nyears, x , title = 'ssa recon (1-5)',                                                 $
     xtitle = '[yr]'
oplot, total( rc[0:4,*], 1 ), thick = 3


;exit

if ( type eq 'ps' ) then begin
  device, /close
endif

end
