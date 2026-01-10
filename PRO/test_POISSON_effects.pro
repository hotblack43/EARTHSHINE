; Cod eto test how Poisson noise influences the making of averages of low-count numbers
; th edata to be estimated constist of a step function going from a 'low' level to a 'high'
; level. Both levels have Poisson noise. A fit is mase to the low level and then this level
; is subtracted from the whole and the average of the whole in a regionis estimated
;
nn=100
openw,3,'ensembles.dat'
for iensembles=1,nn,1 do begin
ntries=1000
openw,1,'data.dat'
for itry=1,ntries,1 do begin
low=1.3
jump=5.0
high=low+jump
n=1000
x=findgen(n)*0.0
x(0:n/2)=low
x(n/2+1:n-1)=high
; replace the x's with Poisson noise
for i=0,n-1,1 do begin
x(i)=randomn(seed,poisson=x(i))
endfor
plot,x
;
w=n/5.
low_estimate=mean(x(n/4-w:n/4+w))
jump_estimate=mean(x(n*3./4.-w:n*3/4+w))-low_estimate
;print,jump_estimate,(jump_estimate-jump)/jump*100.0,' %'
printf,1,(jump_estimate-jump)/jump*100.0
endfor
close,1
data=get_data('data.dat')
data=reform(data(0,*))
histo,data,min(data),max(data),(max(data)-min(data))/100
printf,3,mean(data),stddev(data)/sqrt(999)
endfor
close,3
data=get_data('ensembles.dat')
data=reform(data(0,*))
histo,data,min(data),max(data),(max(data)-min(data))/100
end

