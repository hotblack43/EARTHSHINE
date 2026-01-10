PRO selectwithmouse,x,y,idx
;
print,'Upper left, click'
cursor,xl,yu
wait,.4
print,'lower right, click'
cursor,xr,yd
wait,.4
idx=where(x ge xl and x le xr and y gt yd and y le yu)
oplot,x(idx),y(idx),color=fsc_color('red'),psym=7
return
end

n=100
x=randomu(seed,n)
y=randomu(seed,n)
plot_oo,x,y,psym=7
selectwithmouse,x,y,idx
end
