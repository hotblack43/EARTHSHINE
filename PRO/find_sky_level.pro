openr,1,'listofimagestofit.txt'
while not eof(1) do begin
str=''
readf,1,str
if (str ne 'stop') then begin
im=readfits(str,/silent)
print,format='(2(1x,f12.7),1x,a)',median(im),min(im),str
print,'----------------------------------------------'
endif
endwhile
close,1
end
