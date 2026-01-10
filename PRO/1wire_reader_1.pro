
PRO get_voltage,file,jd,v
openw,3,'voltage.dat'
openr,1,file
s=''
readf,1,s
while not eof(1) do begin
s=''
readf,1,s
len=strlen(s)
	lookfor='.'
for i=0,len-1,1 do begin
	if (i eq 0) then pos=strpos(s,lookfor,i)
	if (i gt 0 and strpos(s,lookfor,i) ne -1 and strpos(s,lookfor,i) ne pos(n_elements(pos)-1)) then pos=[pos,strpos(s,lookfor,i)]
endfor
	lookfor=';'
for i=0,len-1,1 do begin
;	if (i eq 0) then pos=strpos(s,lookfor,i)
	if (i gt 0 and strpos(s,lookfor,i) ne -1 and strpos(s,lookfor,i) ne pos(n_elements(pos)-1)) then pos=[pos,strpos(s,lookfor,i)]
endfor
	lookfor=':'
for i=0,len-1,1 do begin
;	if (i eq 0) then pos=strpos(s,lookfor,i)
	if (i gt 0 and strpos(s,lookfor,i) ne -1 and strpos(s,lookfor,i) ne pos(n_elements(pos)-1)) then pos=[pos,strpos(s,lookfor,i)]
endfor
for k=0,n_elements(pos)-1,1 do begin
	strput,s,' ',pos(k)
endfor
openw,2,'temp.str' & printf,2,s & close,2
data=get_data('temp.str')
dd=reform(data(0,*))
mm=reform(data(1,*))
yy=reform(data(2,*))
hh=reform(data(3,*))
mi=reform(data(4,*))
ss=reform(data(5,*))
v1=reform(data(6,*))
v2=reform(data(7,*))
v=v1+v2/100.0
jd=julday(mm,dd,yy,hh,mi,ss)
printf,3,format='(f20.7,1x,f6.2)',jd-julday(1,1,2009),v
endwhile
close,1
close,3
data=double(get_data('voltage.dat'))
jd=reform(data(0,*))
v=reform(data(1,*))
;idx=where(v gt 10)
;v(idx)=v(idx)-10.24

return
end

file='F:\Program Files\LogTemp\9F000000D86ECA26-V.txt'
get_voltage,file,jd,v
!P.MULTI=[0,1,2]
plot,jd,v,xtitle='DOY in 2009',ytitle='Peltier voltage [V]',charsize=1.7,psym=-1,xrange=[57.97,58.4],yrange=[-0.1,1.6],xstyle=1,title='DS2438 reading LM358N ampl. Peltier. f=330x',ystyle=1
xyouts,/data,58.0,0.4,'lamp on at 10 cm',orientation=90
xyouts,/data,58.075,0.4,'lamp on at 20 cm',orientation=90
xyouts,/data,58.14,0.4,'lamp on at 30 cm',orientation=90
file='F:\Program Files\LogTemp\9F000000D86ECA26-T.txt'
get_voltage,file,jd2,temp
plot,jd2,temp,xtitle='DOY in 2009',ytitle='Temperature [C]',charsize=1.7,psym=-1,xrange=!X.crange,yrange=[19.5,23.5],xstyle=1,ystyle=1
end