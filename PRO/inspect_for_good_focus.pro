







openw,1,'GOODfoucus.txt'
openw,2,'BADfoucus.txt'
files='allfilestoinspectforFOCUS.txt'
get_lun,edm
openr,edm,files
while not eof(edm) do begin
str=''
readf,edm,str
print,str
im=readfits(str,header,/silent)
tvscl,im
a=get_kbrd()
if (a eq 'g') then printf,1,str
if (a eq 'b') then printf,2,str
endwhile
close,1
close,2
close,edm
free_lun,edm
end
