file='B1.txt'
data=get_data(file)
time=reform(data(1,*))
Temp=reform(data(2,*))
plot,time,temp,yrange=[-1,5]
newX=findgen(fix(max(time)-min(time)))+fix(min(time))
newTemp=INTERPOL(Temp,time,newX)
oplot,newx,newtemp,psym=7
openw,1,'B1.globalT.rel61_90.dat'
for i=0,n_elements(newx)-1,1 do begin
	printf,format='(f6.0,1x,f9.3)',1,newx(i),newtemp(i)
endfor
close,1
file='A1B.txt'
data=get_data(file)
time=reform(data(1,*))
Temp=reform(data(2,*))
oplot,time,temp
newX=findgen(fix(max(time)-min(time)))+fix(min(time))
newTemp=INTERPOL(Temp,time,newX)
oplot,newx,newtemp,psym=7
openw,1,'A1B.globalT.rel61_90.dat'
for i=0,n_elements(newx)-1,1 do begin
	printf,format='(f6.0,1x,f9.3)',1,newx(i),newtemp(i)
endfor
close,1
end
