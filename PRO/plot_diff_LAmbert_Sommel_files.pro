PRO get_phase,h,ph
idx=strpos(h,'MPHAS')
ipt=where(idx eq 0)
ph=double(strmid(h(ipt),12,20))
return
end

file='LAmbert_Sommel_files.txt'
openr,1,file
openw,33,'plotme.dat'
while not eof(1) do begin
str=''
readf,1,str
names=strsplit(str,' ',/extract)
imLa=readfits(names(0),header,/silent)
imLo=readfits(names(1),/silent)
diffrat=(imLo-imLa)/(0.5*(imLo+imLa))*100
get_phase,header,ph
;
print,format='(f7.2,1x,f10.3)',ph,max(abs(diffrat(*,256)),/nan)
printf,33,format='(f7.2,1x,f10.3)',ph,max(abs(diffrat(*,256)),/nan)
endwhile
close,1
close,33
data=get_data('plotme.dat')
idx=sort(data(0,*))
data=data(*,idx)
plot,data(0,*),data(1,*),charsize=3
end
