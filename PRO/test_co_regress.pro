n=100
x=randomu(seed,n)*n
a=1.d0
b=2.5d0
noise=randomn(seed,n)*5.0d0
noise=pseudo_t_guarantee_ac1(noise,0.77,1,seed)*15.0d0
y=a+b*x+noise
plot,x,y,psym=7
;
res=linfit(x,y,/double,yfit=yOLS)
oplot,x,yOLS,color=fsc_color('red')
print,'OLS:',res
res=co_regress(x,y,/double,const=konst,yfit=yCO)
oplot,x,yCO,color=fsc_color('blue')
res=[konst,res]
print,' TS CO:',res
; test my own
x=reform(x)
ARRAY=[transpose(y),transpose(x)]
cochraneorcutt,ARRAY,const,res,yfit,BOOT_C_O_sigs
res=[const,res]
print,'PTH CO:',res
end
