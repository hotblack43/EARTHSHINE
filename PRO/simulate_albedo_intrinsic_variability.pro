FUNCTION albedo,d,noisepar
common noisy,oldnoise
noise=randomn(seed)*noisepar
noise=(noise+2.*oldnoise)/3.
oldnoise=noise
period=360.0d0
value=0.3+0.003*sin(d/period*2*!pi)+noise
return,value
end



common noisy,oldnoise
nsim=600
openw,34,'simulations.dat'
for isim=0,nsim-1,1 do begin
oldnoise=0.0
nyears=10
iday=0
noisepar=0.0054
openw,33,'data.dat'
for iyear=1,nyears,1 do begin
for imonth=1,12,1 do begin
for iday=1,30,1 do begin
d=iday+imonth*30+iyear*360.0
printf,33,iday,imonth,iyear,d,albedo(d,noisepar),oldnoise
endfor
endfor
endfor
close,33
;
data=get_data('data.dat')
id=reform(data(0,*))
im=reform(data(1,*))
iy=reform(data(2,*))
d=reform(data(3,*))
alb=reform(data(4,*))
on=reform(data(5,*))
;
plot,d mod 360,(alb-mean(alb))/mean(alb)*100.0,psym=7,xstyle=3,ystyle=3
print,'Monthly stddev of albedo, using daily noise SD=',noisepar
for imo=1,12,1 do begin
idx=where(im eq imo)
climatology=mean(alb(idx))
print,imo,stddev(alb(idx)-climatology)/mean(alb(idx))*100.0
endfor
print,'daily noise SD/mean(alb) in pct: ',noisepar/0.3*100.0,' %.'
ac1=a_correlate(on,1)
tau=(1+ac1)/(1-ac1)
print,'Decorr time for albedo noise: ',tau,' days.'
; analyse the trends now
; select observings nights
rn=randomu(seed,n_elements(d))
jdx=rn gt 2./3.
kdx=where(jdx eq 1)
print,fix(float(n_elements(kdx))/float(n_elements(d))*360),' days per year observing.'
res=linfit(d(kdx),alb(kdx),/double,sigma=sigs)
res=robust_linefit(d(kdx),alb(kdx))
yhat=res(0)+res(1)*d(kdx)
print,'slope: ',res(1),' +/- ',sigs(1)
print,'alb change end to end: ',yhat(0)-yhat(n_elements(yhat)-1)
print,'nyears: ',nyears
print,'per year alb change: ',(yhat(0)-yhat(n_elements(yhat)-1))/mean(alb)*100.,' %.'
printf,34,(yhat(0)-yhat(n_elements(yhat)-1))/mean(alb)*100.
endfor
close,34
data=get_data('simulations.dat')
histo,title='N!years!n='+string(nyears),data,min(data),max(data),(max(data)-min(data))/30.,/cumul,xtitle='% change'
end
