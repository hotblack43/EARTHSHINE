PRO normit,data
l=size(data,/dimensions)
for i=0,l(0)-1,1 do begin
; standardize
data(i,*)=(data(i,*)-mean(data(i,*)))/stddev(data(i,*))
; place on -1,1 range
data(i,*)=data(i,*)-min(data(i,*))
print,min(data(i,*)),max(data(i,*)),i
data(i,*)=data(i,*)/max(data(i,*))*2.0-1.0
print,min(data(i,*)),max(data(i,*)),i
endfor
return
end

FUNCTION replacecommaswithlanks,s
for i=0,strlen(s)-1,1 do begin
c=strmid(s,i,1)
if (c eq ',') then strput,s,' ',i
endfor
return,s
end

openr,1,'16BOXdata_1_frame.csv'
hdr=''
readf,1,hdr
openw,2,'bloc.dat'
while not eof(1) do begin
s=''
readf,1,format='(a)',s
s=replacecommaswithlanks(s)
printf,2,s
endwhile
close,2
close,1
data=get_data('bloc.dat')
l=size(data,/dimensions)
normit,data
openw,1,'MPB.csv'
printf,1,hdr
for irow=0,l(1)-1,1 do begin
printf,1,format='(1000(1x,f10.7,","))',data(*,irow)
endfor
close,1
end
