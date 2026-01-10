data=get_data('alfa_B.dat')
Bjd=reform(data(0,*))
Balfa=reform(data(1,*))
data=get_data('alfa_V.dat')
Vjd=reform(data(0,*))
Valfa=reform(data(1,*))
nB=n_elements(Bjd)
nV=n_elements(Vjd)
openw,44,'data.dat'
for i=0,nB-1,1 do begin
jd=long(Bjd(i))
idx=where(long(Bjd) eq jd)
jdx=where(long(Vjd) eq jd)
printf,44,median(Balfa(idx)),median(Valfa(jdx)),jd
endfor
close,44
spawn,'cat data.dat | sort | uniq > p.dat'
data=get_data('p.dat')
Balfa=reform(data(0,*))
n=n_elements(Balfa)
Valfa=reform(data(1,*))
jd=reform(data(2,*))
!P.CHARSIZE=1.4
!P.CHARTHICK=2
!P.MULTI=[0,1,2]
plot,xstyle=3,ystyle=3,Balfa,Valfa,psym=7,xtitle='B!d!7a!3!n',ytitle='V!d!7a!3!n'
plot,Balfa,Balfa-Valfa,psym=7,xstyle=3,ystyle=3
oplot,[!X.crange],[0,0],linestyle=2
for k=0,n-1,1 do xyouts,Balfa(k),Balfa(k)-Valfa(k),string(jd(k)),charsize=0.8,orientation=-45
for k=0,n-1,1 do print,Balfa(k),Balfa(k)-Valfa(k),jd(k)
end
