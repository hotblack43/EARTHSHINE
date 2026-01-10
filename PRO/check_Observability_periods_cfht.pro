obsname='cfht'
f='Observability_periods_'+obsname+'.dat'
data=get_data(f)
iobs=reform(data(0,*))
starting=reform(data(1,*))
stopping=reform(data(2,*))
n=n_elements(iobs)
for i=0,n-1,1 do begin
openw,33,'data17.dat'
for xJD=(starting(i)),(stopping(i)),1./24./60.d0 do begin
MOONPOS, xJD, ramoon, decmoon
eq2hor, ramoon, decmoon, starting(i), altmoon, azmoon,  OBSNAME=obsname 
SUNPOS, xJD, rasun, decsun
eq2hor, rasun, decsun, starting(i), altsun, azsun,  OBSNAME=obsname 
;print,format='(f15.6,2(1x,f9.3))',xJD,altmoon,altsun
printf,33,format='(f15.6,2(1x,f9.3))',xJD,altmoon,altsun
endfor
close,33
data2=get_data('data17.dat')
t=reform(data2(0,*))
y=reform(data2(1,*))
z=reform(data2(2,*))
plot,t,y,title='Observing period '+string(fix(iobs(i))),xstyle=1,ystyle=1,psym=7,xrange=[long(t(0)),long(t(0))+1.],yrange=[-90,90]
oplot,t,z,psym=4
endfor
end
