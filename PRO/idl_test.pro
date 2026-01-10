file='fredrik.dat'
data=get_data(file)
x=reform(data(0,*))
y=reform(data(1,*))
plot,x,y,psym=7
res=linfit(x,y,sigma=sigs)
oplot,x,res(0)+res(1)*x
;openw,33,'fredrik.dat'
;for i=0,n-1,1 do begin
;printf,33,x(i),y(i)
;endfor
;close,33
print,res
print,sigs
end
