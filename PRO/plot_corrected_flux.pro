PRO allenfunc, X, pars, y;, pder
p=pars
V10=p(0)
rdelta=p(1)
A=p(2)
B=p(3)
pwr=p(4)
phase=abs(x)
phaselaw=A*phase+B*phase^pwr
V=5.0*alog10(rdelta)+V10+phaselaw
y=10^(-V/2.5)
return
end

PRO fitallen,a,da,x,y,yhat
fita=[0,1,1,1,1]
weights=y*0+1.0	; equal weighting
weights=1.0d0/y	; Poisson weighting
yhat = CURVEFIT(x, y, fita=fita,weights, A, da,itmax=100, FUNCTION_NAME='allenfunc',status=stats,/NODERIVATIVE,/double)
print,'Status:',stats
residuals=y-yhat
rmse=sqrt(total(residuals^2)/float(n_elements(residuals)))
print,'RMSE: ',rmse
for k=0,n_elements(a)-1,1 do begin
print,format='(a,g11.4,a,g12.6)','A:',a(k),' +/- ',da(k)
endfor
return
end


data=get_data('corrected_flux.dat')
ibdrf=reform(data(0,*))
ifilt=reform(data(1,*))
phase=reform(data(2,*))
cflux=reform(data(3,*))/2e6
;
plot_io,abs(phase),cflux,psym=7,xtitle='abs(phase)',ytitle='corrected flux',charsize=1.9
colnam=['blue','orange','green','yellow','red']
guess=[-0.23,0.0026,0.026,4e-9,4.]
guess=[-0.566343 , 0.00273755 ,  0.0421477, 4.52022e-09 ,  3.42413]
for jfil=0,4,1 do begin
if (jfil eq 0) then ifil=jfil
if (jfil eq 1) then ifil=2
if (jfil eq 2) then ifil=1
if (jfil eq 3) then ifil=jfil
if (jfil eq 4) then ifil=jfil
print,'-------------------------------'
print,colnam(ifil)
idx=where(ifilt eq ifil)
x=abs(phase(idx))
kdx=sort(x)
x=x(kdx)
y=cflux(idx)
y=y(kdx)
oplot,x,y,psym=7,color=fsc_color(colnam(ifil))
guess=guess*(1.0+randomn(seed,5)*0.04)
;guess(4)=4.0
fitallen,guess,dguess,x,y,yhat
oplot,x,yhat,color=fsc_color(colnam(ifil))
endfor
print,'-------------------------------'
end

