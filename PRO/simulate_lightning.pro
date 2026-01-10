openw,3,'data.dat'
r_e=6371.0e3	; m
for jd=double(julday(1,1,2010,0,0,0)),double(julday(2,1,2010,0,0,0)),1./24./60. do begin
mphase,jd, k
eshine=1370*!pi*r_e^2*(1.-k)	; Watts
lightning=1e12		; Watts
;print,format='(f15.6,1x,f9.3,1x,f9.7)',jd,k,lightning/eshine
printf,3,format='(f15.6,1x,f9.3,1x,f9.7)',jd,k,lightning/eshine
endfor
close,3
data=get_data('data.dat')
jd=reform(data(0,*))
k=reform(data(1,*))
ratio=reform(data(2,*))
!P.MULTI=[0,1,2]
plot_io,(jd-double(julday(1,1,2010,0,0,0)))*24,ratio,xtitle='Time (in hours)',$
ytitle='Lightning/eshine',charsize=1.8,$
xrange=[700-20,700+20],xstyle=1
idx=where(ratio gt 0.001)
plot,k(idx),ratio(idx),xstyle=1,ystyle=1,xtitle='Illuminated fraction',ytitle='Lightning/eshine',$
charsize=1.8
print,min(ratio),max(ratio)
end
