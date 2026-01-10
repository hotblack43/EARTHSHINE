path='C:\cr2\'
files=file_search(path+'IMG*.cr2',count=n)
if (n gt 0) then begin
print,'Found ',n,' .cr2 files to convert to .fts'
openw,1,path+'conversion.bat'
for i=0,n-1,1 do begin
;print,files(i),i
oldname=files(i)
keepoldname=oldname
pos=STRPOS(oldname, '.CR2',4)
strput,oldname,'.tif',pos
printf,1,'convert ',keepoldname,' ',oldname
endfor
close,1
print,'Batch script "conversion.bat" now ready for execution in a DOS window.'
endif
end
