PRO goplotnstuff,x,y,radval,pct
idx=where(x eq radval)
;histo,y(idx),-1,30,0.3,/cum,xtitle='% difference'
getpctile,y(idx),pct,ile
;oplot,[ile,ile],[!Y.crange],linestyle=1
openw,44,'iles.dat',/append
printf,44,radval,pct,ile
close,44
return
end
PRO getpctile,x_in,percentile,value
n=1.0*n_elements(x_in)
idx=sort(x_in)
x=x_in(idx)
value=x(n*percentile/100.)
return
end

spawn,'rm -f iles.dat'
data=get_data('patches.dat')
radfra=reform(data(0,*))
p1=reform(data(1,*))
p2=reform(data(2,*))
pct=reform(data(3,*))
illfrac=reform(data(4,*))
;set_plot,'ps'
;device,/encapsulated
!P.MULTI=[0,2,3]
!X.style=3
!P.charsize=1.3
!P.charthick=3
goplotnstuff,radfra,pct,0.55d0,50
goplotnstuff,radfra,pct,0.65d0,50
goplotnstuff,radfra,pct,0.75d0,50
goplotnstuff,radfra,pct,0.85d0,50
goplotnstuff,radfra,pct,0.95d0,50
data=get_data('iles.dat')
idx=where(data(1,*) eq 50)
!P.MULTI=[0,1,2]
plot,data(0,idx),data(2,idx),psym=7,xtitle='Radial fraction',ytitle='Median [%]'
;device,/close
end
