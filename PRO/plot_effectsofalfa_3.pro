PRO getuniqs,x,uniqs,n
uni=x(sort(x))
uniqs=uni(uniq(uni))
n=n_elements(uniqs)
return
end


close,/all
farver=['red','blue','green','orange']
!P.thick=6
!x.thick=8
!y.thick=8
!P.charsize=2
!P.charthick=5
data=get_data('effectsofalfa_3.dat')
idx=where(data(3,*) lt -19)
data=data(*,idx)
jd=reform(data(0,*))
alfa=reform(data(1,*))
pct=reform(data(2,*))
phase=reform(data(3,*))
!P.MULTI=[0,1,2]
plot,xstyle=3,xrange=[-145,-50],ystyle=3,yrange=[0.1,100],phase,pct,/ylog,psym=7,xtitle='Lunar phase [ FM = 0]',ytitle='% error at DS edge'
;---------------------
getuniqs,alfa,uniqalfas,nuniqs
istep=0.025
for i=0,nuniqs-1,1 do begin
idx=where(alfa eq uniqalfas(i))
oplot,phase(idx),pct(idx),psym=-7,color=fsc_color(farver(i))
xyouts,/normal,0.67,0.74-istep*i,'!7a!3 = '+string(uniqalfas(i),format='(f4.2)')
plots,/normal,[0.6,0.65],[0.75-istep*i,0.75-istep*i],color=fsc_color(farver(i))
endfor
;..........
jdx=where(alfa eq 3.000)
idx=where(alfa eq 2.7597200d0)
plot,xrange=[!X.crange],xstyle=3,yrange=[0,5],phase(idx),pct(idx)/pct(jdx),xtitle='Lunar phase [ FM = 0]',ytitle='(S+D)/D'

end
