












;2455858.1117245  167.0  240.0  148.3     115857941.963568            -2.933384   1   2 VE2     

file='results_BBSO_lin_aligned.txt'
file='results_BBSO_lin_and_log_fixed_2455858.txt'
file='results_BBSO_lin_and_log_fixed_2455917.txt'
filtername=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
!P.CHARSIZE=1
;for itype=1,4,1 do begin
itype=3
!P.MULTI=[0,3,5]
for ifilter=0,4,1 do begin
spawnstr='grep '+filtername(ifilter)+' '+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8}' > datablock.dat"
spawn,spawnstr
;print,spawnstr
data=get_data('datablock.dat')
jd=reform(data(0,*))
fracday=jd-long(jd)
x0=reform(data(1,*))
y0=reform(data(2,*))
radius=reform(data(3,*))
BS=reform(data(4,*))
DS=reform(data(5,*))
iflag=reform(data(6,*))
iflog=reform(data(7,*))
limval=0
fracdaylim=0.
if (itype eq 1) then begin
idx=where(fracday gt fracdaylim and iflag eq 1 and iflog eq 2 and BS gt limval) & titstr='4/5ths and lin images '
endif
if (itype eq 2) then begin
idx=where(fracday gt fracdaylim  and iflag eq 2 and iflog eq 1 and BS gt limval) & titstr='2/3rds and log images '
endif
if (itype eq 3) then begin
idx=where(fracday gt fracdaylim  and iflag eq 2 and iflog eq 2 and BS gt limval) & titstr='2/3rds and lin images '
endif
if (itype eq 4) then begin
idx=where(fracday gt fracdaylim  and iflag eq 1 and iflog eq 1 and BS gt limval) & titstr='4/5ths and log images '
endif
nims=n_elements(idx)

DS_BS=DS/BS*512.0*512.0
plot,psym=7,fracday(idx),DS_BS(idx),xtitle='Fractional day',ytitle='DS/BS',title=titstr+filtername(ifilter),ystyle=3,xrange=[0.08,0.16]
plot,psym=7,fracday(idx),DS(idx),xtitle='Fractional day',ytitle='DS',title=titstr+filtername(ifilter),xrange=[0.08,0.16],ystyle=3
plot,psym=7,fracday(idx),BS(idx),xtitle='Fractional day',ytitle='BS',title=titstr+filtername(ifilter),xrange=[0.08,0.16],ystyle=3
;
print,titstr
print,format='(a,a,i3,a,f8.4,a,f4.1,a,f4.1,a)',filtername(ifilter),' & ',nims,' & ',mean(ds_bs(idx)),' & ',stddev(ds_bs(idx))/mean(ds_bs(idx))*100.,' & ',stddev(ds_bs(idx))/sqrt(nims)/mean(ds_bs(idx))*100.,'\\'
endfor
;endfor
end
