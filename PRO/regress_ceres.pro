
;=======================================================================
;
; PRO  regress_ceres.pro
;
; Version: 2011-03-17
;
; Author:  Hans Gleisner/DMI
;          Peter Thejll added the Durbin-Watson test for 
;          serially correlated residuals.
;=======================================================================


PRO regress_ceres




CERESfile  = 'Data/CERES_Terra_FM1_ES4_ed2.dat'

Ndays = 3653
N10   = 356
N30   = 118
N60   = 59
N90   = 39


;-----------------------------------------------------------------------
; 1. Declare variables.
;-----------------------------------------------------------------------
year     = intarr(Ndays)
doy      = intarr(Ndays)
mjd      = intarr(Ndays)

year_10  = intarr(N10)
doy_10   = intarr(N10)
mjd_10   = intarr(N10)

year_30  = intarr(N30)
doy_30   = intarr(N30)
mjd_30   = intarr(N30)

year_60  = intarr(N60)
doy_60   = intarr(N60)
mjd_60   = intarr(N60)

year_90  = intarr(N90)
doy_90   = intarr(N90)
mjd_90   = intarr(N90)

LW       = fltarr(Ndays) * !VALUES.F_NAN
SW       = fltarr(Ndays) * !VALUES.F_NAN
TOT      = fltarr(Ndays) * !VALUES.F_NAN
TMT      = fltarr(Ndays) * !VALUES.F_NAN

LW_10    = fltarr(N10) * !VALUES.F_NAN
SW_10    = fltarr(N10) * !VALUES.F_NAN
TOT_10   = fltarr(N10) * !VALUES.F_NAN
TMT_10   = fltarr(N10) * !VALUES.F_NAN

LW_30    = fltarr(N30) * !VALUES.F_NAN
SW_30    = fltarr(N30) * !VALUES.F_NAN
TOT_30   = fltarr(N30) * !VALUES.F_NAN
TMT_30   = fltarr(N30) * !VALUES.F_NAN

LW_60    = fltarr(N60) * !VALUES.F_NAN
SW_60    = fltarr(N60) * !VALUES.F_NAN
TOT_60   = fltarr(N60) * !VALUES.F_NAN
TMT_60   = fltarr(N60) * !VALUES.F_NAN

LW_90    = fltarr(N90) * !VALUES.F_NAN
SW_90    = fltarr(N90) * !VALUES.F_NAN
TOT_90   = fltarr(N90) * !VALUES.F_NAN
TMT_90   = fltarr(N90) * !VALUES.F_NAN

dLW      = fltarr(Ndays) * !VALUES.F_NAN
dSW      = fltarr(Ndays) * !VALUES.F_NAN
dTOT     = fltarr(Ndays) * !VALUES.F_NAN
dTMT     = fltarr(Ndays) * !VALUES.F_NAN

dLW_10   = fltarr(N10) * !VALUES.F_NAN
dSW_10   = fltarr(N10) * !VALUES.F_NAN
dTOT_10  = fltarr(N10) * !VALUES.F_NAN
dTMT_10  = fltarr(N10) * !VALUES.F_NAN

dLW_30   = fltarr(N30) * !VALUES.F_NAN
dSW_30   = fltarr(N30) * !VALUES.F_NAN
dTOT_30  = fltarr(N30) * !VALUES.F_NAN
dTMT_30  = fltarr(N30) * !VALUES.F_NAN

dLW_60   = fltarr(N60) * !VALUES.F_NAN
dSW_60   = fltarr(N60) * !VALUES.F_NAN
dTOT_60  = fltarr(N60) * !VALUES.F_NAN
dTMT_60  = fltarr(N60) * !VALUES.F_NAN

dLW_90   = fltarr(N90) * !VALUES.F_NAN
dSW_90   = fltarr(N90) * !VALUES.F_NAN
dTOT_90  = fltarr(N90) * !VALUES.F_NAN
dTMT_90  = fltarr(N90) * !VALUES.F_NAN

pass = bytarr(Ndays)


;-----------------------------------------------------------------------
; 2. Read the daily global-mean time series from file.
;-----------------------------------------------------------------------

;--- CERES and MSU data
line = ''
openr,1,CERESfile
readf,1, line
readf,1, line
readf,1, line
for iday=0,Ndays-1 do begin

  readf,1, line
  strngs = strsplit(line, count=Nsub, /extract)
  if (Nsub EQ 6) then begin
    year[iday] = fix(strngs[0])
    doy[iday]  = fix(strngs[1])
    LW[iday]   = float(strngs[2])
    SW[iday]   = float(strngs[3])
    TOT[iday]  = float(strngs[4])
    TMT[iday]  = float(strngs[5])
    pass[iday] = 1b
  endif else if (Nsub EQ 2) then begin
    year[iday] = fix(strngs[0])
    doy[iday]  = fix(strngs[1])
    pass[iday] = 0b
  endif else begin
    stop, 'ERROR: day ', iday
  endelse

endfor
close,1


;-----------------------------------------------------------------------
; 3. Compute averages
;-----------------------------------------------------------------------

;--- 10-day averages
for i10=0,N10-1 do begin
  iday = 10*i10
  year_10[i10] = year[iday]
  doy_10[i10]  = doy[iday]
  mjd_10[i10]  = mjd[iday]
  LW_10[i10]  = mean(LW[iday:iday+9], /NaN)
  SW_10[i10]  = mean(SW[iday:iday+9], /NaN)
  TOT_10[i10] = mean(TOT[iday:iday+9], /NaN)
  TMT_10[i10] = mean(TMT[iday:iday+9], /NaN)
endfor

;--- 30-day averages
for i30=0,N30-1 do begin
  iday = 30*i30
  year_30[i30] = year[iday]
  doy_30[i30]  = doy[iday]
  mjd_30[i30]  = mjd[iday]
  LW_30[i30]  = mean(LW[iday:iday+29], /NaN)
  SW_30[i30]  = mean(SW[iday:iday+29], /NaN)
  TOT_30[i30] = mean(TOT[iday:iday+29], /NaN)
  TMT_30[i30] = mean(TMT[iday:iday+29], /NaN)
  ; print, i30, iday, year[i30], doy[i30], LW_30[i30], SW_30[i30], NET_30[i30], TMT_30[i30]
endfor

;--- 60-day averages
for i60=0,N60-1 do begin
  iday = 60*i60
  year_60[i60] = year[iday]
  doy_60[i60]  = doy[iday]
  mjd_60[i60]  = mjd[iday]
  LW_60[i60]  = mean(LW[iday:iday+59], /NaN)
  SW_60[i60]  = mean(SW[iday:iday+59], /NaN)
  TOT_60[i60] = mean(TOT[iday:iday+59], /NaN)
  TMT_60[i60] = mean(TMT[iday:iday+59], /NaN)
endfor

;--- 90-day averages
for i90=0,N90-1 do begin
  iday = 90*i90
  print, i90, iday
  year_90[i90] = year[iday]
  doy_90[i90]  = doy[iday]
  mjd_90[i90]  = mjd[iday]
  LW_90[i90]  = mean(LW[iday:iday+89], /NaN)
  SW_90[i90]  = mean(SW[iday:iday+89], /NaN)
  TOT_90[i90] = mean(TOT[iday:iday+89], /NaN)
  TMT_90[i90] = mean(TMT[iday:iday+89], /NaN)
endfor


;-----------------------------------------------------------------------
; 3. Compute the difference time series
;-----------------------------------------------------------------------
for i10=1,N10-1 do begin
  dLW_10[i10]  = LW_10[i10] - LW_10[i10-1]
  dSW_10[i10]  = SW_10[i10] - SW_10[i10-1]
  dTOT_10[i10] = TOT_10[i10] - TOT_10[i10-1]
  dTMT_10[i10] = TMT_10[i10] - TMT_10[i10-1]
endfor

for i30=1,N30-1 do begin
  dLW_30[i30]  = LW_30[i30] - LW_30[i30-1]
  dSW_30[i30]  = SW_30[i30] - SW_30[i30-1]
  dTOT_30[i30] = TOT_30[i30] - TOT_30[i30-1]
  dTMT_30[i30] = TMT_30[i30] - TMT_30[i30-1]
endfor

for i60=1,N60-1 do begin
  dLW_60[i60]  = LW_60[i60] - LW_60[i60-1]
  dSW_60[i60]  = SW_60[i60] - SW_60[i60-1]
  dTOT_60[i60] = TOT_60[i60] - TOT_60[i60-1]
  dTMT_60[i60] = TMT_60[i60] - TMT_60[i60-1]
endfor

for i90=1,N90-1 do begin
  dLW_90[i90]  = LW_90[i90] - LW_90[i90-1]
  dSW_90[i90]  = SW_90[i90] - SW_90[i90-1]
  dTOT_90[i90] = TOT_90[i90] - TOT_90[i90-1]
  dTMT_90[i90] = TMT_90[i90] - TMT_90[i90-1]
endfor


;-----------------------------------------------------------------------
; 4. Scatter plots from anomaly time series.
;-----------------------------------------------------------------------

;--- 10-day averages

set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=12,ysize=12,xoffset=1,yoffset=1
device,file=strcompress('./' + 'regr_LW_TMT_10d.eps',/remove_all)
!P.MULTI = 0
loadct,39

;----- FORMAT string
fmtstr='(a20,f9.4)'

!P.POSITION=[0.17,0.12,0.98,0.90]
xrange = [-0.5,+0.5]
yrange = [-2.0,+2.0]
plot,psym=1,symsize=0.6,TMT_10,LW_10,xstyle=1,xrange=xrange,ystyle=1,yrange=yrange, xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,xtitle='TMT [C]',ytitle='LW [W/m2]', title='10-day averages'

indx = where(finite(TMT_10))
coefs = regress(TMT_10[indx], LW_10[indx], const=const, corr=corr, sigma=sigma, yfit=yhat)
LW_10_residuals=LW_10[indx]-yhat
d=DurbinWatson(LW_10_residuals)
print,format=fmtstr,'LW_10 DW: ',DurbinWatson(LW_10_residuals)
n_in=n_elements(indx)
k_in=1	; 1 regressor, right?
DW_test,d,n_in,k_in,resultPAC,answerPAC,resultNAC,answerNAC
print,'resultPAC,answerPAC,resultNAC,answerNAC:',resultPAC,answerPAC,resultNAC,answerNAC
oplot, xrange, const + coefs[0]*xrange, linestyle=0, thick=2.0
oplot, xrange, const + (coefs[0]+sigma[0])*xrange, linestyle=2, thick=2.0
oplot, xrange, const + (coefs[0]-sigma[0])*xrange, linestyle=2, thick=2.0

oplot, xrange, [0,0], linestyle=1
oplot, [0,0], yrange, linestyle=1

xyouts, /normal, 0.20, 0.83, strcompress( 'r!E2!N = ' + string(corr^2) ), charthick=3.0, charsize=1.1
if (const GE 0.0) then begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ILW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X + ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endif else begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ILW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X - ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endelse
xyouts, /normal, 0.61, 0.16, strcompress( '!4k!X = ' + string(coefs[0],format='(F4.2)') + ' +/- ' + string(2*sigma,format='(F4.2)')), charthick=3.0, charsize=1.1

device,/close


set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=12,ysize=12,xoffset=1,yoffset=1
device,file=strcompress('./' + 'regr_SW_TMT_10d.eps',/remove_all)
!P.MULTI = 0
;loadct,39

!P.POSITION=[0.17,0.12,0.98,0.90]
xrange = [-0.5,+0.5]
yrange = [-2.0,+2.0]
plot,psym=1,symsize=0.6,TMT_10,SW_10,xstyle=1,xrange=xrange,ystyle=1,yrange=yrange, xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,xtitle='TMT [C]',ytitle='SW [W/m2]', title='10-day averages'

indx = where(finite(TMT_10))
coefs = regress(TMT_10[indx], SW_10[indx], const=const, corr=corr, sigma=sigma, yfit=yhat)
SW_10_residuals=SW_10[indx]-yhat
print,format=fmtstr,'SW_10 DW: ',DurbinWatson(SW_10_residuals)
oplot, xrange, const + coefs[0]*xrange, linestyle=0, thick=2.0
oplot, xrange, const + (coefs[0]+sigma[0])*xrange, linestyle=2, thick=2.0
oplot, xrange, const + (coefs[0]-sigma[0])*xrange, linestyle=2, thick=2.0

oplot, xrange, [0,0], linestyle=1
oplot, [0,0], yrange, linestyle=1

xyouts, /normal, 0.20, 0.83, strcompress( 'r!E2!N = ' + string(corr^2) ), charthick=3.0, charsize=1.1
if (const GE 0.0) then begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ISW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X + ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endif else begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ISW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X - ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endelse
xyouts, /normal, 0.61, 0.16, strcompress( '!4k!X = ' + string(coefs[0],format='(F4.2)') + ' +/- ' + string(2*sigma,format='(F4.2)')), charthick=3.0, charsize=1.1

device,/close


set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=12,ysize=12,xoffset=1,yoffset=1
device,file=strcompress('./' + 'regr_NET_TMT_10d.eps',/remove_all)
!P.MULTI = 0
;loadct,39

!P.POSITION=[0.17,0.12,0.98,0.90]
xrange = [-0.5,+0.5]
yrange = [-2.0,+2.0]
plot,psym=1,symsize=0.6,TMT_10,TOT_10,xstyle=1,xrange=xrange,ystyle=1,yrange=yrange, xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,xtitle='TMT [C]',ytitle='LW+SW [W/m2]', title='10-day averages'

indx = where(finite(TMT_10))
coefs = regress(TMT_10[indx], TOT_10[indx], const=const, corr=corr, sigma=sigma, yfit=yhat)
TOT_10_residuals=TOT_10[indx]-yhat
print,format=fmtstr,'TOT_10 DW: ',DurbinWatson(TOT_10_residuals)
oplot, xrange, const + coefs[0]*xrange, linestyle=0, thick=2.0
oplot, xrange, const + (coefs[0]+sigma[0])*xrange, linestyle=2, thick=2.0
oplot, xrange, const + (coefs[0]-sigma[0])*xrange, linestyle=2, thick=2.0

oplot, xrange, [0,0], linestyle=1
oplot, [0,0], yrange, linestyle=1

xyouts, /normal, 0.20, 0.83, strcompress( 'r!E2!N = ' + string(corr^2) ), charthick=3.0, charsize=1.1
if (const GE 0.0) then begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!INET!N = ' + string(coefs,format='(F4.2)') + '*!8T!X + ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endif else begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!INET!N = ' + string(coefs,format='(F4.2)') + '*!8T!X - ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endelse
xyouts, /normal, 0.61, 0.16, strcompress( '!4k!X = ' + string(coefs[0],format='(F4.2)') + ' +/- ' + string(2*sigma,format='(F4.2)')), charthick=3.0, charsize=1.1

device,/close


;--- 30-day averages

set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=12,ysize=12,xoffset=1,yoffset=1
device,file=strcompress('./' + 'regr_LW_TMT_30d.eps',/remove_all)
!P.MULTI = [0,2,3]
;loadct,39

!P.POSITION=[0.17,0.12,0.98,0.90]
xrange = [-0.5,+0.5]
yrange = [-2.0,+2.0]
plot,psym=1,symsize=0.6,TMT_30,LW_30,xstyle=1,xrange=xrange,ystyle=1,yrange=yrange, xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,xtitle='TMT [C]',ytitle='LW [W/m2]', title='30-day averages'

indx = where(finite(TMT_30))
coefs = regress(TMT_30[indx], LW_30[indx], const=const, corr=corr, sigma=sigma, yfit=yhat)
LW_30_residuals=LW_30[indx]-yhat
print,format=fmtstr,'LW_30 DW: ',DurbinWatson(LW_30_residuals)
oplot, xrange, const + coefs[0]*xrange, linestyle=0, thick=2.0
oplot, xrange, const + (coefs[0]+sigma[0])*xrange, linestyle=2, thick=2.0
oplot, xrange, const + (coefs[0]-sigma[0])*xrange, linestyle=2, thick=2.0

oplot, xrange, [0,0], linestyle=1
oplot, [0,0], yrange, linestyle=1

xyouts, /normal, 0.20, 0.83, strcompress( 'r!E2!N = ' + string(corr^2) ), charthick=3.0, charsize=1.1
if (const GE 0.0) then begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ILW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X + ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endif else begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ILW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X - ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endelse
xyouts, /normal, 0.61, 0.16, strcompress( '!4k!X = ' + string(coefs[0],format='(F4.2)') + ' +/- ' + string(2*sigma,format='(F4.2)')), charthick=3.0, charsize=1.1

device,/close


set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=12,ysize=12,xoffset=1,yoffset=1
device,file=strcompress('./' + 'regr_SW_TMT_30d.eps',/remove_all)
!P.MULTI = 0
;loadct,39

!P.POSITION=[0.17,0.12,0.98,0.90]
xrange = [-0.5,+0.5]
yrange = [-2.0,+2.0]
plot,psym=1,symsize=0.6,TMT_30,SW_30,xstyle=1,xrange=xrange,ystyle=1,yrange=yrange, xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,xtitle='TMT [C]',ytitle='SW [W/m2]', title='30-day averages'

indx = where(finite(TMT_30))
coefs = regress(TMT_30[indx], SW_30[indx], const=const, corr=corr, sigma=sigma, yfit=yhat)
SW_30_residuals=SW_30[indx]-yhat
print,format=fmtstr,'SW_30 DW: ',DurbinWatson(SW_30_residuals)
oplot, xrange, const + coefs[0]*xrange, linestyle=0, thick=2.0
oplot, xrange, const + (coefs[0]+sigma[0])*xrange, linestyle=2, thick=2.0
oplot, xrange, const + (coefs[0]-sigma[0])*xrange, linestyle=2, thick=2.0

oplot, xrange, [0,0], linestyle=1
oplot, [0,0], yrange, linestyle=1

xyouts, /normal, 0.20, 0.83, strcompress( 'r!E2!N = ' + string(corr^2) ), charthick=3.0, charsize=1.1
if (const GE 0.0) then begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ISW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X + ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endif else begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ISW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X - ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endelse
xyouts, /normal, 0.61, 0.16, strcompress( '!4k!X = ' + string(coefs[0],format='(F4.2)') + ' +/- ' + string(2*sigma,format='(F4.2)')), charthick=3.0, charsize=1.1

device,/close


set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=12,ysize=12,xoffset=1,yoffset=1
device,file=strcompress('./' + 'regr_NET_TMT_30d.eps',/remove_all)
!P.MULTI = 0
;loadct,39

!P.POSITION=[0.17,0.12,0.98,0.90]
xrange = [-0.5,+0.5]
yrange = [-2.0,+2.0]
plot,psym=1,symsize=0.6,TMT_30,TOT_30,xstyle=1,xrange=xrange,ystyle=1,yrange=yrange, xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,xtitle='TMT [C]',ytitle='LW+SW [W/m2]', title='30-day averages'

indx = where(finite(TMT_30))
coefs = regress(TMT_30[indx], TOT_30[indx], const=const, corr=corr, sigma=sigma, yfit=yhat)
TOT_30_residuals=TOT_30[indx]-yhat
print,format=fmtstr,'TOT_30 DW: ',DurbinWatson(TOT_30_residuals)
oplot, xrange, const + coefs[0]*xrange, linestyle=0, thick=2.0
oplot, xrange, const + (coefs[0]+sigma[0])*xrange, linestyle=2, thick=2.0
oplot, xrange, const + (coefs[0]-sigma[0])*xrange, linestyle=2, thick=2.0

oplot, xrange, [0,0], linestyle=1
oplot, [0,0], yrange, linestyle=1

xyouts, /normal, 0.20, 0.83, strcompress( 'r!E2!N = ' + string(corr^2) ), charthick=3.0, charsize=1.1
if (const GE 0.0) then begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!INET!N = ' + string(coefs,format='(F4.2)') + '*!8T!X + ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endif else begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!INET!N = ' + string(coefs,format='(F4.2)') + '*!8T!X - ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endelse
xyouts, /normal, 0.61, 0.16, strcompress( '!4k!X = ' + string(coefs[0],format='(F4.2)') + ' +/- ' + string(2*sigma,format='(F4.2)')), charthick=3.0, charsize=1.1

device,/close



;-----------------------------------------------------------------------
; 5. Scatter plots from differenced anomaly data.
;-----------------------------------------------------------------------

;--- 10-day averages

set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=12,ysize=12,xoffset=1,yoffset=1
device,file=strcompress('./' + 'regr_dLW_dTMT_10d.eps',/remove_all)
!P.MULTI = 0
;loadct,39

!P.POSITION=[0.17,0.12,0.98,0.90]
xrange = [-0.5,+0.5]
yrange = [-2.0,+2.0]
plot,psym=1,symsize=0.6,dTMT_10,dLW_10,xstyle=1,xrange=xrange,ystyle=1,yrange=yrange, xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,xtitle='dTMT [C]',ytitle='dLW [W/m2]', title='10-day averages'

indx = where(finite(dTMT_10))
coefs = regress(dTMT_10[indx], dLW_10[indx], const=const, corr=corr, sigma=sigma, yfit=yhat)
dLW_10_residuals=dLW_10[indx]-yhat
print,format=fmtstr,'dLW_10 DW: ',DurbinWatson(dLW_10_residuals)
oplot, xrange, const + coefs[0]*xrange, linestyle=0, thick=2.0
oplot, xrange, const + (coefs[0]+sigma[0])*xrange, linestyle=2, thick=2.0
oplot, xrange, const + (coefs[0]-sigma[0])*xrange, linestyle=2, thick=2.0

oplot, xrange, [0,0], linestyle=1
oplot, [0,0], yrange, linestyle=1

xyouts, /normal, 0.20, 0.83, strcompress( 'r!E2!N = ' + string(corr^2) ), charthick=3.0, charsize=1.1
if (const GE 0.0) then begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ILW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X + ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endif else begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ILW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X - ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endelse
xyouts, /normal, 0.61, 0.16, strcompress( '!4k!X = ' + string(coefs[0],format='(F4.2)') + ' +/- ' + string(2*sigma,format='(F4.2)')), charthick=3.0, charsize=1.1

device,/close


set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=12,ysize=12,xoffset=1,yoffset=1
device,file=strcompress('./' + 'regr_dSW_dTMT_10d.eps',/remove_all)
!P.MULTI = 0
;loadct,39

!P.POSITION=[0.17,0.12,0.98,0.90]
xrange = [-0.5,+0.5]
yrange = [-2.0,+2.0]
plot,psym=1,symsize=0.6,dTMT_10,dSW_10,xstyle=1,xrange=xrange,ystyle=1,yrange=yrange, xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,xtitle='dTMT [C]',ytitle='dSW [W/m2]', title='10-day averages'

indx = where(finite(dTMT_10))
coefs = regress(dTMT_10[indx], dSW_10[indx], const=const, corr=corr, sigma=sigma, yfit=yhat)
dSW_10_residuals=dSW_10[indx]-yhat
print,format=fmtstr,'dSW_10 DW: ',DurbinWatson(dSW_10_residuals)
oplot, xrange, const + coefs[0]*xrange, linestyle=0, thick=2.0
oplot, xrange, const + (coefs[0]+sigma[0])*xrange, linestyle=2, thick=2.0
oplot, xrange, const + (coefs[0]-sigma[0])*xrange, linestyle=2, thick=2.0

oplot, xrange, [0,0], linestyle=1
oplot, [0,0], yrange, linestyle=1

xyouts, /normal, 0.20, 0.83, strcompress( 'r!E2!N = ' + string(corr^2) ), charthick=3.0, charsize=1.1
if (const GE 0.0) then begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ISW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X + ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endif else begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ISW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X - ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endelse
xyouts, /normal, 0.61, 0.16, strcompress( '!4k!X = ' + string(coefs[0],format='(F4.2)') + ' +/- ' + string(2*sigma,format='(F4.2)')), charthick=3.0, charsize=1.1

device,/close


set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=12,ysize=12,xoffset=1,yoffset=1
device,file=strcompress('./' + 'regr_dNET_dTMT_10d.eps',/remove_all)
!P.MULTI = 0
;loadct,39

!P.POSITION=[0.17,0.12,0.98,0.90]
xrange = [-0.5,+0.5]
yrange = [-2.0,+2.0]
plot,psym=1,symsize=0.6,dTMT_10,dTOT_10,xstyle=1,xrange=xrange,ystyle=1,yrange=yrange, xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,xtitle='dTMT [C]',ytitle='dLW+dSW [W/m2]', title='10-day averages'

indx = where(finite(dTMT_10))
coefs = regress(dTMT_10[indx], dTOT_10[indx], const=const, corr=corr, sigma=sigma, yfit=yhat)
dTOT_10_residuals=dTOT_10[indx]-yhat
print,format=fmtstr,'dTOT_10 DW: ',DurbinWatson(dTOT_10_residuals)
oplot, xrange, const + coefs[0]*xrange, linestyle=0, thick=2.0
oplot, xrange, const + (coefs[0]+sigma[0])*xrange, linestyle=2, thick=2.0
oplot, xrange, const + (coefs[0]-sigma[0])*xrange, linestyle=2, thick=2.0

oplot, xrange, [0,0], linestyle=1
oplot, [0,0], yrange, linestyle=1

xyouts, /normal, 0.20, 0.83, strcompress( 'r!E2!N = ' + string(corr^2) ), charthick=3.0, charsize=1.1
if (const GE 0.0) then begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!INET!N = ' + string(coefs,format='(F4.2)') + '*!8T!X + ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endif else begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!INET!N = ' + string(coefs,format='(F4.2)') + '*!8T!X - ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endelse
xyouts, /normal, 0.61, 0.16, strcompress( '!4k!X = ' + string(coefs[0],format='(F4.2)') + ' +/- ' + string(2*sigma,format='(F4.2)')), charthick=3.0, charsize=1.1

device,/close


;--- 30-day averages

set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=12,ysize=12,xoffset=1,yoffset=1
device,file=strcompress('./' + 'regr_dLW_dTMT_30d.eps',/remove_all)
!P.MULTI = 0
;loadct,39

!P.POSITION=[0.17,0.12,0.98,0.90]
xrange = [-0.5,+0.5]
yrange = [-2.0,+2.0]
plot,psym=1,symsize=0.6,dTMT_30,dLW_30,xstyle=1,xrange=xrange,ystyle=1,yrange=yrange, xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,xtitle='dTMT [C]',ytitle='dLW [W/m2]', title='30-day averages'

indx = where(finite(dTMT_30))
coefs = regress(dTMT_30[indx], dLW_30[indx], const=const, corr=corr, sigma=sigma, yfit=yhat)
dLW_30_residuals=dLW_30[indx]-yhat
print,format=fmtstr,'dLW_30 DW: ',DurbinWatson(dLW_30_residuals)
oplot, xrange, const + coefs[0]*xrange, linestyle=0, thick=2.0
oplot, xrange, const + (coefs[0]+sigma[0])*xrange, linestyle=2, thick=2.0
oplot, xrange, const + (coefs[0]-sigma[0])*xrange, linestyle=2, thick=2.0

oplot, xrange, [0,0], linestyle=1
oplot, [0,0], yrange, linestyle=1

xyouts, /normal, 0.20, 0.83, strcompress( 'r!E2!N = ' + string(corr^2) ), charthick=3.0, charsize=1.1
if (const GE 0.0) then begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ILW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X + ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endif else begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ILW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X - ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endelse
xyouts, /normal, 0.61, 0.16, strcompress( '!4k!X = ' + string(coefs[0],format='(F4.2)') + ' +/- ' + string(2*sigma,format='(F4.2)')), charthick=3.0, charsize=1.1

device,/close


set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=12,ysize=12,xoffset=1,yoffset=1
device,file=strcompress('./' + 'regr_dSW_dTMT_30d.eps',/remove_all)
!P.MULTI = 0
;loadct,39

!P.POSITION=[0.17,0.12,0.98,0.90]
xrange = [-0.5,+0.5]
yrange = [-2.0,+2.0]
plot,psym=1,symsize=0.6,dTMT_30,dSW_30,xstyle=1,xrange=xrange,ystyle=1,yrange=yrange, xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,xtitle='dTMT [C]',ytitle='dSW [W/m2]', title='30-day averages'

indx = where(finite(dTMT_30))
coefs = regress(dTMT_30[indx], dSW_30[indx], const=const, corr=corr, sigma=sigma, yfit=yhat)
dSW_30_residuals=dSW_30[indx]-yhat
print,format=fmtstr,'dSW_30 DW: ',DurbinWatson(dSW_30_residuals)
oplot, xrange, const + coefs[0]*xrange, linestyle=0, thick=2.0
oplot, xrange, const + (coefs[0]+sigma[0])*xrange, linestyle=2, thick=2.0
oplot, xrange, const + (coefs[0]-sigma[0])*xrange, linestyle=2, thick=2.0

oplot, xrange, [0,0], linestyle=1
oplot, [0,0], yrange, linestyle=1

xyouts, /normal, 0.20, 0.83, strcompress( 'r!E2!N = ' + string(corr^2) ), charthick=3.0, charsize=1.1
if (const GE 0.0) then begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ISW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X + ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endif else begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!ISW!N = ' + string(coefs,format='(F4.2)') + '*!8T!X - ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endelse
xyouts, /normal, 0.61, 0.16, strcompress( '!4k!X = ' + string(coefs[0],format='(F4.2)') + ' +/- ' + string(2*sigma,format='(F4.2)')), charthick=3.0, charsize=1.1

device,/close


set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=12,ysize=12,xoffset=1,yoffset=1
device,file=strcompress('./' + 'regr_dNET_dTMT_30d.eps',/remove_all)
!P.MULTI = 0
;loadct,39

!P.POSITION=[0.17,0.12,0.98,0.90]
xrange = [-0.5,+0.5]
yrange = [-2.0,+2.0]
plot,psym=1,symsize=0.6,dTMT_30,dTOT_30,xstyle=1,xrange=xrange,ystyle=1,yrange=yrange, xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,xtitle='dTMT [C]',ytitle='dLW+dSW [W/m2]', title='30-day averages'

indx = where(finite(dTMT_30))
coefs = regress(dTMT_30[indx], dTOT_30[indx], const=const, corr=corr, sigma=sigma, yfit=yhat)
dTOT_30_residuals=dTOT_30[indx]-yhat
print,format=fmtstr,'dTOT_30 DW: ',DurbinWatson(dTOT_30_residuals)
oplot, xrange, const + coefs[0]*xrange, linestyle=0, thick=2.0
oplot, xrange, const + (coefs[0]+sigma[0])*xrange, linestyle=2, thick=2.0
oplot, xrange, const + (coefs[0]-sigma[0])*xrange, linestyle=2, thick=2.0

oplot, xrange, [0,0], linestyle=1
oplot, [0,0], yrange, linestyle=1

xyouts, /normal, 0.20, 0.83, strcompress( 'r!E2!N = ' + string(corr^2) ), charthick=3.0, charsize=1.1
if (const GE 0.0) then begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!INET!N = ' + string(coefs,format='(F4.2)') + '*!8T!X + ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endif else begin
  xyouts, /normal, 0.20, 0.78, strcompress( '!4U!X!INET!N = ' + string(coefs,format='(F4.2)') + '*!8T!X - ' + string(abs(const),format='(F4.2)') ), charthick=3.0, charsize=1.1
endelse
xyouts, /normal, 0.61, 0.16, strcompress( '!4k!X = ' + string(coefs[0],format='(F4.2)') + ' +/- ' + string(2*sigma,format='(F4.2)')), charthick=3.0, charsize=1.1

device,/close




slut:

END
