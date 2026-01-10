filtername='B'
filtername='V'
filtername='IRCUT'	; IRCUT and VE1 combined
data=get_data('BBSOLIN_'+filtername+'_data.dat')
t=reform(data(0,*))
idx=sort(t)
data=data(*,idx)
t=reform(data(0,*))
exptime=reform(data(1,*))
oneside=reform(data(2,*))
otherside=reform(data(3,*))
tot=reform(data(4,*))
; make the choice of series to analyse
;...........................................................................
; total counts
y=tot
tstr='BBSO-linear cleaned '+filtername+' band total counts'
;...........................................................................
; total flux
y=tot/exptime
tstr='BBSO-linear cleaned '+filtername+' band total flux'
;...........................................................................
; DS counts
y=((otherside le oneside)*otherside+oneside*(oneside lt otherside))
tstr='BBSO-linear cleaned '+filtername+' band DS counts'
;...........................................................................
; DS flux
y=((otherside le oneside)*otherside+oneside*(oneside lt otherside))
y=y/exptime
tstr='BBSO-linear cleaned '+filtername+' band DS flux'
;...........................................................................
; get rid of junk
idx=where(y gt 0 and y lt 2000)
t=t(idx)
y=y(idx)
; add a test signal
;period=1.0d0;+1./27.3d0
;y=y+1e6*sin(t*!pi*2./period)
; get the power spectrum
scargle,t,y,freq,pow
wave=!PI*2./freq 
!P.CHARSIZE=2
!P.MULTI=[0,1,3]
;plot_oi,xstyle=3,wave,pow,xtitle='2!7p!3/f [days]',ytitle='Power',xrange=[0.01,(max(t)-min(t))/2.],title=tstr
plot_io,ystyle=3,psym=3,t,abs(y),xtitle='JD',ytitle='Observation',title=tstr
plot,xstyle=3,wave,pow,xtitle='2!7p!3/f [days]',ytitle='Power',xrange=[0.9,1.1],title=tstr
plot,xstyle=3,wave,pow,xtitle='2!7p!3/f [days]',ytitle='Power',xrange=[15,60],title=tstr
openw,33,strcompress(tstr+'_powerspectrum.dat',/remove_all)
for i=0,n_elements(pow)-1,1 do begin
printf,33,freq(i),wave(i),pow(i)
endfor
close,33
end
