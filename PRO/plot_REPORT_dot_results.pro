PRO goplot,name
common iflags,iflag
data=get_data(name)
jd=reform(data(0,*))
unknown=reform(data(1,*))
alfa=reform(data(2,*))
ratio=reform(data(3,*))
pcterr=reform(data(4,*))
if (iflag eq 314) then begin
plot,jd,ratio
iflag=911
endif else begin
oplot,jd,ratio
endelse
stop
return
end

common iflags,iflag
iflag=314
file='2455865_REPORT.results'
openr,1,file
openw,2,'VE2.dat'
openw,3,'B.dat'
openw,4,'VE1.dat'
openw,5,'IRCUT.dat'
openw,6,'V.dat'
while not eof(1) do begin
a=0.0
b=0.0
c=0.0
d=0.0
e=0.0
s=''
readf,1,a,b,c,d,e,s
s=strcompress(s,/remove_all)
if (s eq 'VE2') then printf,2,a,b,c,d,e,s
if (s eq 'B') then printf,3,a,b,c,d,e,s
if (s eq 'VE1') then printf,4,a,b,c,d,e,s
if (s eq 'IRCUT') then printf,5,a,b,c,d,e,s
if (s eq 'V') then printf,6,a,b,c,d,e,s
endwhile
close,1
close,2
close,3
close,4
close,5
close,6
;
goplot,'VE1.dat'
goplot,'VE2.dat'
goplot,'V.dat'
goplot,'B.dat'
goplot,'IRCUT.dat'
end


