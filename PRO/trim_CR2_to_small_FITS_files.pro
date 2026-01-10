path='C:\cr2\'
w=100
files=file_search(path+'IMG*.tif',count=n)
if (n gt 0) then begin
print,'Found ',n,' .cr2 files to convert to .fts'
for i=0,n-1,1 do begin
	im=read_tiff(files(i))

for j=0,2,1 do begin
RGorB=reform(im(j,*,*))
if (max(RGorB) lt 65000L) then begin
if (j eq 0) then name=path+'R_'+strmid(files(i),7,strlen(files(i))-7)
if (j eq 1) then name=path+'G_'+strmid(files(i),7,strlen(files(i))-7)
if (j eq 2) then name=path+'B_'+strmid(files(i),7,strlen(files(i))-7)
strput,name,'.fts',strpos(name,'.tif')
writefits,name,RGorB
print,name,max(im)
endif
endfor

endfor
endif
end
