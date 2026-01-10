;************************************************************************
;
; Reads MSL from Church&White(2006)
; and global temperatures from GISS (Hansen)
; redoing Rahmstorf(2007) analysis.
;
;***********************************************************************
;
; Language: IDL
;
;***********************************************************************
;
; Programmed by:  Torben Schmith, 9/2-2007.
;
; Last update by: Torben Schmith, 9/2-2007.
;
;***********************************************************************

; define plotting environment

type = 'ps'

if ( type eq 'x') then begin
  set_plot,'x'
  device, pseudo_color = 8, decomposed = 0, retain = 2
  iwin = 0
  xsize = 600
  ysize = 850
endif

if ( type eq 'ps' ) then begin
  set_plot,'ps'
  device, filename="/ts/tmp/plot.ps",                      $
          xsize = 16., xoffset = 2., ysize = 25., yoffset = 2., $
          /color, bits_per_pixel = 8
   !p.thick = 3
   !x.thick = 3
   !y.thick = 3
   !p.font = 0
endif

!y.omargin = [5,15]
!p.charsize = 1.

deg2rad = !pi /180.

iyfirst     = 1880
iylast      = 2001
nyear       = iylast - iyfirst + 1
nyears      = iyfirst + indgen(nyear)

year        = intarr( 12*nyear )
month       = intarr( 12*nyear )

for iyr = iyfirst, iylast do begin
   for imo = 1, 12 do begin
      year[  12*(iyr-iyfirst) + (imo-1) ] = iyr
      month[ 12*(iyr-iyfirst) + (imo-1) ] = imo
   endfor
endfor


; read sea level

indir = '/ts/PSMSL/data/Church-White_2006/'
infile = 'church_white_grl_gmsl.lis'

msl   = fltarr( 12*nyear )

fracyr_in     =0.
msl_in     = 0.
msl_std_in = 0.

luin = 11
openr, luin, indir + infile

while not eof( luin ) do begin
   readf, luin, fracyr_in, msl_in, msl_std_in, format = '(f9.4, 3x, f6.2, 4x, f5.2 )'
   iyr_in = fix( fracyr_in )
   imo_in = round( 12 * ( fracyr_in - iyr_in ) + 0.5 )
   if iyr_in ge iyfirst and iyr_in le iylast then begin
      print, fracyr_in, iyr_in, imo_in, msl_in, msl_std_in
   msl[12*(iyr_in-iyfirst) + imo_in-1] = msl_in
   endif

endwhile

close, luin

; annual values

msl_yr = fltarr( nyear )

for iyr = iyfirst, iylast do begin
   isel = where( year eq iyr )
   msl_yr[iyr-iyfirst] = mean( msl[ isel ] )
endfor


if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title = 'msl series'
  iwin = iwin + 1
endif

!p.multi = [0,1,1]

plot, nyears, msl_yr ,  /ynozero,                                            $
   xtitle = "Year" ,                                                           $
   ytitle = "[mm]"

xyouts, 0.5, 0.95, "Global sea level!C"                                   $
            + "Church&White (2006)!C"                                                  $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate


; read temperature anomalies (station based )

indir = '/ts/GISS/data/gistemp/'
infile = 'GLB_Ts.txt'

temp_stat   = fltarr( 12*nyear )

iyr_in     =0.
itemp_in   = fltarr( 12 )

dummy_rd = ''

luin = 11
openr, luin, indir + infile

for i = 1, 7 do begin
   readf, luin, dummy_rd
endfor

readf, luin, dummy_rd

for i = 1, 21 do begin
   readf, luin, iyr_in, itemp_in, format = '(i4, 1x, 12(2x, i3)   )'

   if iyr_in ge iyfirst and iyr_in le iylast then begin
      isel = where( year eq iyr_in )
      temp_stat[isel] = float( itemp_in ) / 100
   endif
endfor

for i = 1, 2 do begin
   readf, luin, dummy_rd
endfor

for ibig = 1, 5 do begin
   for i = 1, 20 do begin
      readf, luin, iyr_in, itemp_in, format = '(i4, 1x, 12(2x, i3)   )'

      if iyr_in ge iyfirst and iyr_in le iylast then begin
         isel = where( year eq iyr_in )
         temp_stat[isel] = float( itemp_in ) / 100
      endif
   endfor

   for i = 1, 2 do begin
      readf, luin, dummy_rd
   endfor
endfor

for i = 1, 6 do begin
   readf, luin, iyr_in, itemp_in, format = '(i4, 1x, 12(2x, i3)   )'

   if iyr_in ge iyfirst and iyr_in le iylast then begin
      isel = where( year eq iyr_in )
      temp_stat[isel] = float( itemp_in ) / 100
   endif
endfor

close, luin


; read temperature anomalies (land-ocean )

indir = '/ts/GISS/data/gistemp/'
infile = 'GLB.Ts+dSST.txt'

temp_landocean   = fltarr( 12*nyear )

iyr_in     =0.
itemp_in   = fltarr( 12 )

dummy_rd = ''

luin = 11
openr, luin, indir + infile

for i = 1, 8 do begin
   readf, luin, dummy_rd
endfor

readf, luin, dummy_rd

for i = 1, 21 do begin
   readf, luin, iyr_in, itemp_in, format = '(i4, 1x, 12(2x, i3)   )'

   if iyr_in ge iyfirst and iyr_in le iylast then begin
      isel = where( year eq iyr_in )
      temp_landocean[isel] = float( itemp_in ) / 100
   endif
endfor

for i = 1, 2 do begin
   readf, luin, dummy_rd
endfor

for ibig = 1, 5 do begin
   for i = 1, 20 do begin
      readf, luin, iyr_in, itemp_in, format = '(i4, 1x, 12(2x, i3)   )'

      if iyr_in ge iyfirst and iyr_in le iylast then begin
         isel = where( year eq iyr_in )
         temp_landocean[isel] = float( itemp_in ) / 100
      endif
   endfor

   for i = 1, 2 do begin
      readf, luin, dummy_rd
   endfor
endfor

for i = 1, 6 do begin
   readf, luin, iyr_in, itemp_in, format = '(i4, 1x, 12(2x, i3)   )'

   if iyr_in ge iyfirst and iyr_in le iylast then begin
      isel = where( year eq iyr_in )
      temp_landocean[isel] = float( itemp_in ) / 100
   endif
endfor

close, luin


; annual values

temp_stat_yr = fltarr( nyear )
temp_landocean_yr = fltarr( nyear )

for iyr = iyfirst, iylast do begin
   isel = where( year eq iyr )
   temp_stat_yr[iyr-iyfirst] = mean( temp_stat[ isel ] )
   temp_landocean_yr[iyr-iyfirst] = mean( temp_landocean[ isel ] )
endfor


if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title = 'temp series'
  iwin = iwin + 1
endif

!p.multi = [0,1,2]

plot, nyears, temp_stat_yr ,  /ynozero,                                        $
   title = 'Station based',                                                    $
   xtitle = "Year" ,                                                           $
   ytitle = "Temperature anomaly nomaly[deg. C]"

plot, nyears, temp_landocean_yr ,  /ynozero,                                   $
   title = 'Land-ocean',                                                       $
   xtitle = "Year" ,                                                           $
   ytitle = "Temperature anomaly nomaly[deg. C]"

xyouts, 0.5, 0.95, "Global temperature anomaly!C"                                   $
            + "GISS!C"                                                         $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title = 'temp scat'
  iwin = iwin + 1
endif

!p.multi = [0,1,1]

plot, temp_landocean_yr, temp_stat_yr ,  /ynozero,                                        $
   xtitle = "Land-ocean [deg. C]" ,                                                           $
   ytitle = "Station [deg. C]", psym = 1, /isotropic

xyouts, 0.5, 0.95, "Global temperature anomaly!C"                                   $
            + "GISS!C"                                                         $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate


; annual data

;***temp = temp_stat_yr
temp = temp_landocean_yr

msl  = msl_yr

dmsl = fltarr( nyear )

for iyr = iyfirst+5, iylast-5 do begin
   isel = where( ( nyears ge iyr-5 ) and ( nyears le iyr+5 ) )
   res = linfit( nyears[isel], msl[isel] )
   dmsl[iyr-iyfirst] = res[1]
endfor


; detrend

;***temp = detrend( temp )
;***dmsl = detrend( dmsl )


if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title = 'ann series'
  iwin = iwin + 1
endif

!p.multi = [0,1,3]

plot, nyears , temp ,  /ynozero,                                        $
   xtitle = "Year" ,                                                           $
   ytitle = "Temperature anomaly [deg. C]"

plot, nyears, msl ,  /ynozero,                                            $
   xtitle = "Year" ,                                                           $
   ytitle = "Sea level [mm]"

plot, nyears, dmsl ,  /ynozero,                                            $
   xtitle = "Year" ,                                                           $
   ytitle = "Rate of sea level change [mm/year]"

oplot, !x.crange, [0., 0.], linestyle = 1

xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "Annual data!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate


res = linfit( temp[1:*], dmsl[1:*], yfit = yfit )
b = res[1]


if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title = 'temp msl scat'
  iwin = iwin + 1
endif

!p.multi = [0,1,1]

plot, temp[1:*], dmsl[1:*] ,  /ynozero,                                        $
   xtitle = "Temp [deg. C]" ,                                                           $
   ytitle = "Rate of sesa level change[mm/year]", psym = 1

oplot, temp[1:*], yfit, linestyle = 2

r = correlate(temp[1:*] ,dmsl[1:*] )
r_detrend = correlate( detrend( temp[1:*]) ,detrend( dmsl[1:*] ) )

xyouts, 0.97 * !x.window[0] + 0.03 * !x.window[1],                          $
  0.05 * !y.window[0] + 0.95 * !y.window[1], /normal ,                      $
  "Corr. coeff.: " + string( r, format = '(f5.2)' )

xyouts, 0.97 * !x.window[0] + 0.03 * !x.window[1],                          $
  0.10 * !y.window[0] + 0.90 * !y.window[1], /normal ,                      $
  "Corr. coeff. (detrend): " + string( r_detrend, format = '(f5.2)' )

xyouts, 0.97 * !x.window[0] + 0.03 * !x.window[1],                          $
  0.15 * !y.window[0] + 0.85 * !y.window[1], /normal ,                      $
  "Slope: " + string( b, format = '(f5.2)' )

xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "scatterplot - annual data!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate


; extend series back- and forward

ny_x  = 16

; least square

nyears_x = fix( makex( iyfirst-ny_x, iylast+ny_x, 1 ) )

res = linfit( indgen( ny_x ), temp[0:ny_x-1 ] )
temp_before_ls = res[0] + res[1] * ( (-1) - reverse( (-1) * indgen( ny_x ) ) )

res = linfit( indgen( ny_x ), msl[0:ny_x-1 ] )
msl_before_ls = res[0] + res[1] * ( (-1) - reverse( (-1) * indgen( ny_x ) ) )

res = linfit( reverse( -1. * indgen( ny_x ) ), temp[nyear-ny_x:nyear-1 ] )
temp_after_ls = res[0] + res[1] * ( indgen( ny_x ) + 1 )

res = linfit( reverse( -1. * indgen( ny_x ) ), msl[nyear-ny_x:nyear-1 ] )
msl_after_ls = res[0] + res[1] * ( indgen( ny_x ) + 1 )


; mirroring

temp_before_mir = 2. * temp[0]       - reverse( temp[1:ny_x] )
temp_after_mir  = 2. * temp[nyear-1] - reverse( temp[nyear-1-ny_x:nyear-1-1] )

msl_before_mir  = 2. * msl[0]        - reverse( msl[1:ny_x] )
msl_after_mir   = 2. * msl[nyear-1]  - reverse( msl[nyear-1-ny_x:nyear-1-1] )


; padding

temp_x_ls = [temp_before_ls, temp, temp_after_ls ]
msl_x_ls = [msl_before_ls, msl, msl_after_ls ]

temp_x_mir = [temp_before_mir, temp, temp_after_mir ]
msl_x_mir = [msl_before_mir, msl, msl_after_mir ]


if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'extend'
  iwin = iwin + 1
endif

!p.multi = [0,1,2]

plot, nyears_x, temp_x_ls , title = 'temperature', xtitle = '[yr]', linestyle = 0
oplot, nyears_x, temp_x_mir, linestyle = 2
oplot, [iyfirst, iyfirst], !y.crange, linestyle = 1
oplot, [iylast, iylast], !y.crange, linestyle = 1

plot, nyears_x, msl_x_ls , title = 'mean sea level', xtitle = '[yr]', linestyle = 0
oplot, nyears_x, msl_x_mir, linestyle = 2
oplot, [iyfirst, iyfirst], !y.crange, linestyle = 1
oplot, [iylast, iylast], !y.crange, linestyle = 1

xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "Extended series!c"                                              $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith", /idldate


; select padding method to be used hereafter

temp_x = temp_x_mir
msl_x = msl_x_mir


; ssa

wlen = 15
nderiv = 4
error = 0.

ssa, temp_x, wlen, var_ssa, trace_ssa, teof , tpc, rc_temp, nderiv = nderiv, ghil_mo = error

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'ssa-spec temp'
  iwin = iwin + 1
endif

!p.multi = [0,1,1]

plot, indgen(nderiv)+1, var_ssa / trace_ssa, title = 'SSA spectrum', /ylog, psym = 4
oploterr, indgen(nderiv)+1, var_ssa / trace_ssa, error / trace_ssa

xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "ssa-eigenspectrum - temp!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith", /idldate

nmc = 1000
siglev = .95

eigrank = indgen(nderiv)+1

;***sigcomp = [ 1 ]

mcssa, temp_x,wlen, var_mcssa, trace_mcssa, teof_mcssa , tpc_mcssa, rc,       $
       var0_u, var0_l, nderiv = nderiv, siglev = siglev,                          $
       nmc = nmc, rho1 = rho1, assoc_freq = assoc_freq, teof_fit = teof_fit, $
       sigcomp = sigcomp


print, 'rho: ' , rho1

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'mcssa-spec temp'
  iwin = iwin + 1
endif

!p.multi = [0,1,3]

ymin = min( [var0_l, var_ssa - 2 * error ] / trace_ssa )
ymax = max( [var0_u, var_ssa + 2 * error ] / trace_ssa )

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


xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "mcssa-eigenspectrum - temp!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith", /idldate


; reconstruction

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'rc temp'
  iwin = iwin + 1
endif

!p.multi = [0,1,3]

plot, nyears_x, temp_x , title = 'ssa recon (1)',                                                 $
     xtitle = '[yr]', psym = 3
oplot, nyears_x, rc_temp[0,*] + mean( temp_x )
oplot, [iyfirst, iyfirst], !y.crange, linestyle = 1
oplot, [iylast, iylast], !y.crange, linestyle = 1

plot, nyears_x, temp_x , title = 'ssa recon (1-2)',                                                 $
     xtitle = '[yr]', psym = 3
oplot, nyears_x, total( rc_temp[0:1,*], 1 ) +  mean( temp_x )
oplot, [iyfirst, iyfirst], !y.crange, linestyle = 1
oplot, [iylast, iylast], !y.crange, linestyle = 1


plot, nyears_x, temp_x , title = 'ssa recon (1-3)',                                                 $
     xtitle = '[yr]', psym = 3
oplot, nyears_x, total( rc_temp[0:2,*], 1 ) +  mean( temp_x )
oplot, [iyfirst, iyfirst], !y.crange, linestyle = 1
oplot, [iylast, iylast], !y.crange, linestyle = 1


xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "ssa-reconstruction - temp!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith", /idldate


; ssa - msl

ssa, msl_x,wlen, var_ssa, trace_ssa, teof , tpc, rc_msl, nderiv = nderiv, ghil_mo = error

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'ssa-spec msl'
  iwin = iwin + 1
endif

!p.multi = [0,1,1]

plot, indgen(nderiv)+1, var_ssa / trace_ssa, title = 'SSA spectrum', /ylog, psym = 4
oploterr, indgen(nderiv)+1, var_ssa / trace_ssa, error / trace_ssa

xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "ssa-eigenspectrum - msl!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith", /idldate


mcssa, msl_x,wlen, var_mcssa, trace_mcssa, teof_mcssa , tpc_mcssa, rc_mcssa,       $
       var0_u, var0_l, nderiv = nderiv, siglev = siglev,                          $
       nmc = nmc, rho1 = rho1, assoc_freq = assoc_freq, teof_fit = teof_fit, $
       sigcomp = sigcomp


print, 'rho: ' , rho1

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'mcssa-spec msl'
  iwin = iwin + 1
endif

!p.multi = [0,1,3]

ymin = min( [var0_l, var_ssa - 2 * error ] / trace_ssa )
ymax = max( [var0_u, var_ssa + 2 * error ] / trace_ssa )

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


xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "mcssa-eigenspectrum - msl!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith", /idldate


; reconstruction

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title =  'rc msl'
  iwin = iwin + 1
endif

!p.multi = [0,1,3]

plot, nyears_x, msl_x , title = 'ssa recon (1)',                                                 $
     xtitle = '[yr]', psym = 3
oplot, nyears_x, total( rc_msl[0:0,*], 1 ) + mean( msl_x )
oplot, [iyfirst, iyfirst], !y.crange, linestyle = 1
oplot, [iylast, iylast], !y.crange, linestyle = 1

plot, nyears_x, msl_x , title = 'ssa recon (1-2)',                                                 $
     xtitle = '[yr]', psym = 3
oplot, nyears_x, total( rc_msl[0:1,*], 1 ) + mean( msl_x )
oplot, [iyfirst, iyfirst], !y.crange, linestyle = 1
oplot, [iylast, iylast], !y.crange, linestyle = 1

plot, nyears_x, msl_x , title = 'ssa recon (1-3)',                                                 $
     xtitle = '[yr]', psym = 3
oplot, nyears_x, total( rc_msl[0:2,*], 1 ) + mean( msl_x )
oplot, [iyfirst, iyfirst], !y.crange, linestyle = 1
oplot, [iylast, iylast], !y.crange, linestyle = 1

xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "ssa-reconstruction - msl!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith", /idldate


; smoothen series -

temp_smooth = total( rc_temp[0:0,*], 1 ) + mean( temp_x )
;***temp_smooth = smooth( temp_x, 31 )

temp_smooth = temp_smooth[ny_x:nyear+ny_x-1]

msl_smooth  = total( rc_msl[0:0,*], 1 ) + mean( msl_x )
;***msl_smooth  = smooth( msl_x, 31 )

dmsl_smooth_fit10 = fltarr( nyear + 2 * ny_x )

for iyr = iyfirst-ny_x+5, iylast+ny_x-5 do begin
   isel = where( ( nyears_x ge iyr-5 ) and ( nyears_x le iyr+5 ) )
   res = linfit( nyears_x[isel], msl_smooth[isel] )
   dmsl_smooth_fit10[iyr-(iyfirst-ny_x) ] = res[1]
endfor

msl_smooth = msl_smooth[ny_x:nyear+ny_x-1]
dmsl_smooth_fit10 = dmsl_smooth_fit10[ny_x:nyear+ny_x-1]

dmsl_smooth_diff = fltarr( nyear )

for iyr = iyfirst+1, iylast do begin
   dmsl_smooth_diff[iyr-iyfirst] = msl_smooth[iyr-iyfirst] - msl_smooth[iyr-iyfirst-1]
endfor

dmsl_smooth_lagr3 = deriv( msl_smooth )


if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title = 'smooth series'
  iwin = iwin + 1
endif

!p.multi = [0,1,3]

plot, nyears, temp_smooth ,  /ynozero,                                        $
   xtitle = "Year" ,                                                           $
   ytitle = "Temperature anomaly[deg. C]"

plot, nyears, msl_smooth ,  /ynozero,                                        $
   xtitle = "Year" ,                                                           $
   ytitle = "Sea level [mm]"
oplot, nyears, msl ,  psym = 3

plot, nyears, dmsl_smooth_fit10 ,  /ynozero, linestyle = 0,                      $
   xtitle = "Year" ,                                                           $
   ytitle = "Rate of sea level change [mm/year]"

oplot, nyears, dmsl_smooth_diff, linestyle = 1
oplot, nyears, dmsl_smooth_lagr3, linestyle = 2


xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "Smoothed data!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate


; regression of smoothenend series

dmsl_smooth = dmsl_smooth_fit10


res = linfit( temp_smooth, dmsl_smooth, yfit = yfit )
b = res[1]


if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title = ' msl recon '
  iwin = iwin + 1
endif

!p.multi = [0,1,1]

plot, nyears, dmsl_smooth ,  /ynozero, linestyle = 0,                      $
   xtitle = "Year" ,                                                           $
   ytitle = "Rate of sea level change [mm/year]"

oplot, nyears, yfit, linestyle = 2

xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "msl reonstruction - smoothed data!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate


if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title = 'temp msl scat'
  iwin = iwin + 1
endif

!p.multi = [0,1,2]

plot, temp_smooth, dmsl_smooth ,  /ynozero,                                        $
   xtitle = "Temp [deg. C]" ,                                                           $
   ytitle = "Rate of sesa level change[mm/year]", psym = 1

oplot, temp_smooth, yfit, linestyle = 2

r = correlate(temp_smooth ,dmsl_smooth )
r_detrend = correlate( detrend( temp_smooth) ,detrend( dmsl_smooth ) )

xyouts, 0.97 * !x.window[0] + 0.03 * !x.window[1],                          $
  0.05 * !y.window[0] + 0.95 * !y.window[1], /normal ,                      $
  "Corr. coeff.: " + string( r, format = '(f5.2)' )

xyouts, 0.97 * !x.window[0] + 0.03 * !x.window[1],                          $
  0.10 * !y.window[0] + 0.90 * !y.window[1], /normal ,                      $
  "Corr. coeff. (detrend): " + string( r_detrend, format = '(f5.2)' )

xyouts, 0.97 * !x.window[0] + 0.03 * !x.window[1],                          $
  0.15 * !y.window[0] + 0.85 * !y.window[1], /normal ,                      $
  "Slope: " + string( b, format = '(f5.2)' )


plot, temp_smooth, dmsl_smooth - yfit ,  /ynozero,                                $
   title = 'Residuals',                                                    $
   xtitle = "Temp [deg. C]" ,                                       $
   ytitle = "[mm/year]", psym = 1
oplot, !x.crange, [0., 0.], linestyle = 1

r1 = a_correlate( dmsl_smooth - yfit, 1 )

xyouts, 0.97 * !x.window[0] + 0.03 * !x.window[1],                          $
  0.05 * !y.window[0] + 0.95 * !y.window[1], /normal ,                      $
  "lag-1 ACF: " + string( r1, format = '(f5.2)' )


xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "scatterplot -smoothed data!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate


; regresion with a trend added


res = regress( [ transpose( temp_smooth), transpose( nyears)], dmsl_smooth, sigma = sigma )

print, 'regression with time trend added:'
print, transpose( res )
print, sigma


; binning

lbin = 5
nbin = nyear / lbin
sel_bin = ( nyear - nbin * lbin ) / 2 + lbin / 2 + lbin * indgen( nbin ) - 1 + 2
nyears_bin = nyears[ sel_bin ]
nyear_bin = n_elements( nyears_bin )

temp_bin = fltarr( nyear_bin)
dmsl_bin = fltarr( nyear_bin)


for ibin = 1, nbin do begin
   dmsl_bin[ibin-1] = mean( dmsl_smooth[ sel_bin[ibin-1]-2:sel_bin[ibin-1]+2 ] )
   temp_bin[ibin-1] = mean( temp_smooth[ sel_bin[ibin-1]-2:sel_bin[ibin-1]+2 ] )
endfor


if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title = 'smooth bin series'
  iwin = iwin + 1
endif

!p.multi = [0,1,2]

plot, nyears_bin, temp_bin ,  /ynozero,                                        $
   xtitle = "Year" ,                                                           $
   ytitle = "Temperature[deg. C]"

plot, nyears_bin, dmsl_bin ,  /ynozero,                                            $
   xtitle = "Year" ,                                                           $
   ytitle = "Rate of sea level change [mm/year]"

xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "Smoothed and binned data!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate


res = linfit( temp_bin, dmsl_bin, yfit = yfit_bin, sigma = sigma )
b = res[1]

if ( type eq 'x') then begin
  window, iwin, xsize = xsize, ysize = ysize, title = 'bin temp msl scat'
  iwin = iwin + 1
endif

!p.multi = [0,1,2]

plot, temp_bin, dmsl_bin ,  /ynozero,                                $
   xtitle = "Temp [deg. C]" ,                                       $
   ytitle = "Rate of sesa level change[mm/year]", psym = 1

oplot, temp_bin, yfit_bin, linestyle = 2

r = correlate(temp_bin ,dmsl_bin )
r_detrend = correlate( detrend( temp_bin) ,detrend( dmsl_bin ) )
xyouts, 0.97 * !x.window[0] + 0.03 * !x.window[1],                          $
  0.05 * !y.window[0] + 0.95 * !y.window[1], /normal ,                      $
  "Corr. coeff.: " + string( r, format = '(f5.2)' )

xyouts, 0.97 * !x.window[0] + 0.03 * !x.window[1],                          $
  0.10 * !y.window[0] + 0.90 * !y.window[1], /normal ,                      $
  "Corr. coeff. (detrend): " + string( r_detrend, format = '(f5.2)' )

xyouts, 0.5, 0.95, "Rahmstorf 2007!C"                                          $
            + "scatterplot - smoothed and binned data!c"                                     $
            + "Period: " + string(iyfirst, format='(i4)' )                     $
            + " - " + string(iylast, format='(i4)' ) ,                         $
              /normal, charsize = 2, alignment = 0.5

signature, "T. Schmith, DMI", pos = [0.9, 0.0 ], /idldate


;exit

if ( type eq 'ps' ) then begin
  device, /close
endif

end