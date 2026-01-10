file='coeffs_for_exposures.dat'
data=get_data(file)
t=fltarr(5,361)
ph=findgen(180*2+1)-180.
for i=0,4,1 do begin
print,i
t(i,*)=data(0)+data(1,i)*(ph)+data(2,i)*ph*ph
endfor
plot,ph,10^t(0,*)/10^t(1,*)
oplot,ph,10^t(1,*)/10^t(1,*)
oplot,ph,10^t(2,*)/10^t(1,*)
oplot,ph,10^t(3,*)/10^t(1,*)
oplot,ph,10^t(4,*)/10^t(1,*)
end
