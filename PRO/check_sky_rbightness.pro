PRO getsmallestcornervalue,im,smallest
w=14
c1=im(0:w,0:w)
c2=im(0:w,511-w:511)
c3=im(511-w:511,0:w)
c4=im(511-w:511,511-w:511)
help,c1,c2,c3,c4
each=[median(c1),median(c2),median(c3),median(c4)]
print,each
smallest=min(each)
return
end

files='considerthese'
openw,33,'medianskyvaluesatcorner.dat'
openr,1,files
while not eof(1) do begin
str=''
readf,1,str
im=readfits(str)
getsmallestcornervalue,im,smallest
printf,33,format='(f9.4,1x,a)',smallest,str
endwhile
close,1
close,33
end
