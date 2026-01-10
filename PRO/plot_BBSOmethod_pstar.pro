FUNCTION cotan,x
;x is in radians
value=cos(x)/sin(x)
return,value
end

PRO VOIGT_FUN,x,a,F
common stuff2,y
apar=a(0)
bpar=a(1)
F=voigt(apar,x)/bpar
return
end

PRO pthfunc,x,a,f
f=a(0)+a(1)*cos((x-a(2))*!dtor)
return
end

data=get_data('BBSOmethod_pstar.dat')
data=get_data('BBSOmethod_pstar_SMOOTHimages.dat')
idx=sort(data(1,*))
data=data(*,idx)
jd=reform(data(0,*))
phase=reform(data(1,*))
pstar=reform(data(2,*))
sd_pstar=reform(data(3,*))
mystery=21.377267	; empirical scale factor required
pstar=pstar*mystery
sd_pstar=sd_pstar*mystery
ph=reform(data(4,*))
fL=reform(data(5,*))
;
!P.MULTI= [0,1,2]
!P.charsize=1.9
plot,yrange=[0,1],ystyle=3,title='Test of BBS method on synthetic images',xrange=[-180,180],xstyle=3,xtitle='Lunar phase [FM = 0]',ytitle='A!dBBSO!n',phase,pstar,psym=1,charsize=1.8,thick=3
oplot,[!x.crange],[0,0]
        P=[randomu(seed,3)]
        x=phase
        y=pstar
        weights=y*0.0+1.0
        yfit = CURVEFIT( X, Y, Weights, P, TOL=1.0d-8,  /DOUBLE, FUNCTION_NAME='pthfunc' , /NODERIVATIVE,status=stat )
print,'Status: ',stat
xx=findgen(360)-180
pthfunc,xx,p,yhat
oplot,xx,yhat,color=fsc_color('red')
print,median(pstar),median(sd_pstar),median(sd_pstar)/median(pstar)*100.
plot,ystyle=3,xrange=[-180,180],yrange=[-4.9,0.9],xstyle=3,phase,(pstar-0.3)/0.3*100,psym=1,xtitle='Lunar phase [FM = 0]',ytitle='% error in A!dE!n'
oplot,[!X.crange],[0,0]
;
end
