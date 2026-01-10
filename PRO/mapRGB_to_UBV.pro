data=get_data('UBV_vs_RGB.dat')
U=reform(data(1,*))
B=reform(data(2,*))
V=reform(data(3,*))
; omit the brightest - theyare probably saturated
 idx=where(U gt 2 and B gt 2 and V gt 2)
 data=data(*,idx)
U=reform(data(1,*))
B=reform(data(2,*))
V=reform(data(3,*))
Rcmos=reform(data(4,*))
Gcmos=reform(data(5,*))
Bcmos=reform(data(6,*))
!P.MULTI=[0,3,3]
plot,xstyle=3,ystyle=3,U,Rcmos,xtitle='U',ytitle='R!cmos!n',psym=7
plot,xstyle=3,ystyle=3,B,Rcmos,xtitle='B',ytitle='R!cmos!n',psym=7
plot,xstyle=3,ystyle=3,V,Rcmos,xtitle='V',ytitle='R!cmos!n',psym=7
plot,xstyle=3,ystyle=3,U,Gcmos,xtitle='U',ytitle='G!cmos!n',psym=7
plot,xstyle=3,ystyle=3,B,Gcmos,xtitle='B',ytitle='G!cmos!n',psym=7
plot,xstyle=3,ystyle=3,V,Gcmos,xtitle='V',ytitle='G!cmos!n',psym=7
plot,xstyle=3,ystyle=3,U,Bcmos,xtitle='U',ytitle='B!cmos!n',psym=7
plot,xstyle=3,ystyle=3,B,Bcmos,xtitle='B',ytitle='B!cmos!n',psym=7
plot,xstyle=3,ystyle=3,V,Bcmos,xtitle='V',ytitle='B!cmos!n',psym=7
print,'  U,B,V     R,G,B    Correlation'
for i=1,3,1 do begin
for j=4,6,1 do begin
print,i,j,correlate(data(i,*),data(j,*))
endfor
endfor
end
