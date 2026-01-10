FUNCTION SINUS, X, P
  RETURN, P[2] + p(1)*sin(x/p(0)*2.0d0*!pi+p(3))
END


start = [randomn(seed,4)]
start(0)=0.015
data=get_data('cycle.dat')
t=reform(data(0,*))
mn=reform(data(1,*))
med=reform(data(2,*))
plot,t-t(0),mn,ystyle=3,xstyle=3,psym=7
res= MPFITFUN('SINUS', t, mn,rerr, start,niter=1000)
oplot,t-t(0),sinus(t,res),color=fsc_color('red')
print,res(2)*24.*60.
end
