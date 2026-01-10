n=20
t1=systime(1)
for i=0,n-1,1 do begin
X = read_ascii('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\Eshine\data_eshine\Earth.1d.map',data_start=0)
endfor
t2=systime(1)
delta_ascii=t2-t1
print,delta_ascii
;-----------
t1=systime(1)
for i=0,n*268-1,1 do begin
openu,11,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\Eshine\data_eshine\Earth.1d.map.binary'
l=[0L,0L]
readu,11,l
x=fltarr(l)
readu,11,x
close,11
endfor
t2=systime(1)
print,delta_ascii/(t2-t1)
end