files=file_search('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455825/*.fit*',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i),header)
print,header
print,files(i)
endfor
end
