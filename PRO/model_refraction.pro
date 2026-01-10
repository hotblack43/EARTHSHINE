; model refraction as function of p T and hum
openw,3,'plotme.dat'
for z=45,90,1. do begin
wave=0.55
for pressure=500.0,750,50 do begin
temp=5.
relhum=0.0
 zref2 = refrac(z*!dtor,wave,pressure,temp,relhum)/!dtor
 zref1 = refrac((z+0.5)*!dtor,wave,pressure,temp,relhum)/!dtor
 print,pressure,90-z,(zref1-zref2)/0.5*100.0,' % ',zref1,zref2
 printf,3,pressure,90-z,(0.5-(zref1-zref2))/0.5*100.0
 endfor
 endfor
 close,3
 data=get_data('plotme.dat')
 p=reform(data(0,*))
 z=reform(data(1,*))
 pct=reform(data(2,*))
 plot_io,z,pct,xtitle='Altitude (degrees)',ytitle='Circular distortion: (1-a/b)*100',charsize=2,psym=7,xrange=[9,50],xstyle=1,ystyle=1,title='Image distortion'
plots,[30,50],[0.06,0.06]
plots,[9,19],[0.6,0.6]
plots,[13,23],[0.3,0.3]
xyouts,/data,30,0.12,'750 mm Hg',charsize=1.4
xyouts,/data,12,0.08,'3.5 km or 500 mm Hg',charsize=1.4
 end
