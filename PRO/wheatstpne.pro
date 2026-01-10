openw,14,'aha.dat'
R1=1.1
r2=1.
r3=10.
vs=10.
for r4=9.,11.,0.1 do begin
v=vs*(r4/(r3+r4)-r2/(r1+r2))
printf,14,r4,v
endfor
close,14
data=get_data('aha.dat')
r4=reform(data(0,*))
v=reform(data(1,*))
plot,r4,v,xtitle='Thermistor resistance',ytitle='Bridge voltage',charsize=2,psym=-4
end