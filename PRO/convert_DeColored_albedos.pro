openr,1,'DeColored_albedos.tex'
spawn,'cat part11.tex > DeCo_Table.tex'
openw,78,'DeCo_Table.tex',/append
while not eof(1) do begin
str1=''
readf,1,str1
str2=''
readf,1,str2
str3=''
readf,1,str3
str4=''
readf,1,str4
str5=''
readf,1,str5
str6=''
readf,1,str6
bits=strsplit(str1,' ',/extract)
JD=bits(1)
Balb=double(bits(2))
Balberr=double(bits(3))
bits=strsplit(str2,' ',/extract)
Valb=double(bits(2))
Valberr=double(bits(3))
bits=strsplit(str3,' ',/extract)
VE1alb=double(bits(2))
VE1alberr=double(bits(3))
bits=strsplit(str4,' ',/extract)
VE2alb=double(bits(2))
VE2alberr=double(bits(3))
bits=strsplit(str5,' ',/extract)
IRCUTalb=double(bits(2))
IRCUTalberr=double(bits(3))
if (Balberr ne 0.0) then Bstr=JD+'&'+string(Balb,format='(f6.4)')+'$\pm$'+string(Balberr,format='(f6.4)')+'&'
if (Balberr eq 0.0) then Bstr=JD+'&'+'--'+'&'
if (Valberr ne 0.0) then Vstr=string(Valb,format='(f6.4)')+'$\pm$'+string(Valberr,format='(f6.4)')+'&'
if (Valberr eq 0.0) then Vstr='--'+'&'
if (VE1alberr ne 0.0) then VE1str=string(VE1alb,format='(f6.4)')+'$\pm$'+string(VE1alberr,format='(f6.4)')+'&'
if (VE1alberr eq 0.0) then VE1str='--'+'&'
if (VE2alberr ne 0.0) then VE2str=string(VE2alb,format='(f6.4)')+'$\pm$'+string(VE2alberr,format='(f6.4)')+'\\'
if (VE2alberr eq 0.0) then VE2str='--'+'\\'
if (IRCUTalberr ne 0.0) then IRCUTstr=string(IRCUTalb,format='(f6.4)')+'$\pm$'+string(IRCUTalberr,format='(f6.4)')+'&'
if (IRCUTalberr eq 0.0) then IRCUTstr='--'+'&'
print,strcompress(Bstr+Vstr+IRCUTstr+VE1str+VE2str,/remove_all)
printf,78,strcompress(Bstr+Vstr+IRCUTstr+VE1str+VE2str,/remove_all)


endwhile
close,1
close,78
spawn,'cat part22.tex >> DeCo_Table.tex'
end
