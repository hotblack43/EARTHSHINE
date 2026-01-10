ifile=2	; =2 (is is alldata.., 2 is 77-92)
if (ifile eq 1) then begin
file='allphotodata.header'
openr,1,file
s=''
readf,1,s
openw,12,'lasilla_kV_JD_91_96.dat'
openw,14,'lasilla_kV_yymmddhhmi_91_96.dat'
endif
if (ifile eq 2) then begin
file='lasilla_77_92.dat'
openr,1,file
openw,12,'lasilla_kV_JD_77_92.dat'
openw,14,'lasilla_kV_yymmddhhmi_77_92.dat'
endif
while not eof(1) do begin
if (ifile eq 1) then begin
readf,1,HJD,date,kU,kB1,kB,kB2,KV1,kV,kG
caldat,double(HJD)+2440000.0d0,mm,dd,yy,hh,mi
print,format='(f10.0,1x,f7.2,2(f6.3,1x))',julday(1,1,yy),HJD+2440000L-julday(1,1,yy),kV,0.0
printf,12,format='(f12.3,1x2(f6.3,1x))',double(HJD)+2440000.0d0,kV,0.0
printf,14,format='(i4,1x,i2,1x,i2,1x,i2,1x,i2,1x,2(f6.3,1x))',yy,mm,dd,hh,mi,kV,0.0
endif
if (ifile eq 2) then begin
readf,1,dummy,MJD,kU,d,kB1,d,kB,d,kB2,d,KV1,d,kV,d,kG,d
caldat,double(MJD)+2400000.0d0,mm,dd,yy,hh,mi
print,format='(f10.0,1x,f7.2,2(f6.3,1x))',julday(1,1,yy),MJD+2400000L-julday(1,1,yy),kV,0.0
printf,12,format='(f12.3,1x2(f6.3,1x))',double(MJD)+2400000.0d0,kV,0.0
printf,14,format='(i4,1x,i2,1x,i2,1x,i2,1x,i2,1x,2(f6.3,1x))',yy,mm,dd,hh,mi,kV,0.0
endif
endwhile
close,1
close,14
close,12
end