path='C:\cr2\'
w=100
files=file_search(path+'IMG*.tif',count=n)
if (n gt 0) then begin
print,'Found ',n,' .cr2 files to convert to .fts'
for i=0,n-1,1 do begin
	im=read_tiff(files(i))
for j=0,2,1 do begin
RGorB=reform(im(j,*,*))
if (j eq 0) then name=path+'R_'+strmid(files(i),7,strlen(files(i))-7)
if (j eq 1) then name=path+'G_'+strmid(files(i),7,strlen(files(i))-7)
if (j eq 2) then name=path+'B_'+strmid(files(i),7,strlen(files(i))-7)
print,name
writefits,name,RGorB
endfor
endfor
endif
end
