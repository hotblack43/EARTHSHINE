BSnumber='3748'
bias=readfits('TTAURI/superbias.fits')
files=file_search('/media/thejll/OLDHD/MOONDROPBOX/','*EXTSTAR_'+BSnumber+'*.fits*',count=n)
for i=0,n-1,1 do begin
print,files(i)
im=readfits(files(i),header)
l=size(Im,/dimensions)
print,max(im),l
endfor
end
