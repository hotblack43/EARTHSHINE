data=get_data('stars.cat')
v=reform(data(0,*))+17.8
verr=reform(data(1,*))
b=reform(data(2,*))+17.3
berr=reform(data(3,*))
bminusverr=sqrt(berr^2+verr^2)
ve1=reform(data(4,*))
ve1err=reform(data(5,*))
vminusve1err=sqrt(verr^2+ve1err^2)
; make B- vs V diagram
!P.MULTI=[0,1,2]
plot,b-v,v,ytitle='V (arb. offset)',xtitle='B-V (arb. offset)',psym=7,ystyle=1,xstyle=1,xrange=[-.75,2.75],yrange=[16.4,5]

for i=0,n_elements(v)-1,1 do begin
oplot,[(b(i)-v(i))-bminusverr(i),(b(i)-v(i))+bminusverr(i)],[v(i),v(i)]
oplot,[(b(i)-v(i)),(b(i)-v(i))],[v(i)-verr(i),v(i)+verr(i)]
endfor
; make B-v vs V-Ve1 diagram
plot,b-v,v-ve1,ytitle='V-VE1 (arb. offset)',xtitle='B-V (arb. offset)',psym=7,xrange=[max(b-v),min(b-v)],yrange=[max(v-ve1),min(v-ve1)],xstyle=3,ystyle=3
for i=0,n_elements(v)-1,1 do begin
oplot,[(b(i)-v(i))-bminusverr(i),(b(i)-v(i))+bminusverr(i)],[v(i),v(i)]
oplot,[(b(i)-v(i)),(b(i)-v(i))],[(v(i)-ve1(i))-vminusve1err(i),(v(i)-ve1(i))+vminusve1err(i)]
endfor
end
