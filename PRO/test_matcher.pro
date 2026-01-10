PRO match_level,x1,y1,x2,y2,x2new,y2new
; Will match the y levels of the second to the first
; OUTPUT is in x2new and y2new
xstart=min([x1,x2])
xend=max([x1,x2])
idx=where(x2 ge xstart and x2 le xend)
jdx=where(x1 ge xstart and x1 le xend)
; robust fit to red crosses
res1=robust_linefit(x2(idx),y2(idx))
Y_redline=res1(0)+res1(1)*x2(idx)
;oplot,x2(idx),Y_redline,psym=1,color=fsc_color('red')
; robust fit to white crosses
res2=robust_linefit(x1(jdx),y1(jdx))
Y_greenline=res2(0)+res2(1)*x2(idx)
;oplot,x2(jdx),Y_greenline,psym=1,color=fsc_color('green')
; difference between red and green lines
difference=Y_redline-Y_greenline
; now shift red points down by that difference
x2new=x2(idx)
y2new=y2-difference
return
end






n=40
x1=randomu(seed,n)*n
a=1.0
b=2.0
eta=3.3
noise=randomn(seed,n)
y1=a+b*x1+eta*noise

n=20
x2=randomu(seed,n)*n+n/2
a=6.0
b=1.0
eta=2.4
noise=randomn(seed,n)
y2=a+b*x2+eta*noise
y2(n/2)=y2(n/2)*2.
plot,x1,y1,psym=7,yrange=[min([y1,y2]),max([y1,y2])]
match_level,x1,y1,x2,y2,x2new,y2new
oplot,x2,y2,psym=7,color=fsc_color('red')
oplot,x2new,y2new,psym=7,color=fsc_color('green')
end

