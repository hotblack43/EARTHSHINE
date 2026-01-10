; first generate a forcing series
n=1000
x=randomu(seed,n)	; just white noise, or ...
x=pseudo_t_guarantee_ac1(x,0.77,1,seed)	; i.e. generate an AR1 process with AC1=0.77
;
; now generate two series forced by the above
y1=fltarr(n)
y2=fltarr(n)
y1(0)=1.0
y2(0)=9.0
alfa1=0.05	; memory coeffcieint for series 1 'small'
alfa2=0.95	; memory coeffcieint for series 2 'large'
for i=1,n-1,1 do begin
coupling_term=0.01*(y2(i-1)-y1(i-1))
y1(i)=alfa1*y1(i-1)+x(i)
y2(i)=alfa2*y2(i-1)+x(i)-coupling_term
endfor
; center both series
y1=(y1-mean(y1))/stddev(y1)
y2=(y2-mean(y2))/stddev(y2)
;
; test for Granger causality:
print,'y1 is a series with small memory of its own past.'
print,'y2 is a series with large memory of its own past.'
print,' Correlation at shift -1 (i.e. past values of y1 vs present values of y2):',correlate(y1,shift(y2,-1))
print,' Correlation at shift +1 (i.e. past values of y2 vs present values of y1):',correlate(y1,shift(y2,+1))
!P.MULTI=[0,2,3]
plot,indgen(100)-50,c_correlate(y2,y1,indgen(100)-50),xtitle='Shifts on y2',ytitle='R',charsize=1.4
plots,[0,0],!Y.crange
for shifts=-2,2,1 do plot,y1,shift(y2,shifts),psym=7,title='y2 shift:'+string(shifts),charsize=1.3,xtitle='y1',ytitle='Shifted y2',xrange=[-4,4],yrange=[-4,4],/isotropic
end

