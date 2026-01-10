PRO call_table,table,jd,l_out,b_out,paaxis_out,palimb_out
si=size(table,/dimensions)
ncols=5
nrows=si(1)
l_out=-911.1
b_out=-911.1
paaxis_out=-911.1
palimb_out=-911.1
for i=0,nrows-2,1 do begin
if (jd ge table(0,i) and jd lt table(0,i+1)) then begin
	jdfract=(jd-table(0,i))/(table(0,i+1)-table(0,i))
	l_out=table(1,i)+jdfract*(table(1,i+1)-table(1,i))
	b_out=table(2,i)+jdfract*(table(2,i+1)-table(2,i))
	paaxis_out=table(3,i)+jdfract*(table(3,i+1)-table(3,i))
	palimb_out=table(4,i)+jdfract*(table(4,i+1)-table(4,i))
endif
endfor
return
end


PRO get_libration,jd,l_out,b_out,paaxis_out,palimb_out
common remember,donethis,table
if (donethis eq 314) then begin
nBIG=10000
table=fltarr(5,nBIG)
file='libration.dat'
openr,68,file
line=''
astr=''
l=0.0
b=0.0
paaxis=0.0
palimb=0.0
i=0
while not eof(68) do begin
readf,68,line
astr=strmid(line,0,19)
l=float(strmid(line,20,8))
b=float(strmid(line,28,8))
paaxis=float(strmid(line,36,10))
palimb=float(strmid(line,46,10))
yy=fix(strmid(astr,0,4))
mm=fix(strmid(astr,5,2))
dd=fix(strmid(astr,8,2))
hh=fix(strmid(astr,12,2))
mi=fix(strmid(astr,15,2))
se=fix(strmid(astr,18,2))
table(0,i)=double(julday(mm,dd,yy,hh,mi,se))
table(1,i)=l
table(2,i)=b
table(3,i)=paaxis
table(4,i)=palimb
i=i+1
if (i-1 gt nBIG) then begin
	print,'nBIG is too small!'
	stop
endif
endwhile
close,68
table=table(*,0:i-1)
donethis=1
call_table,table,jd,l_out,b_out,paaxis_out,palimb_out
endif

if (donethis ne 314) then begin
	call_table,table,jd,l_out,b_out,paaxis_out,palimb_out
endif
return
end

common remember,donethis,table
donethis=314
jd=double(julday(5,25,2004,21,45,12))
get_libration,jd,l,b,paaxis,palimb
print,jd,l,b,paaxis,palimb
end

