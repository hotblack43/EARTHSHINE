files=file_search('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\movie\*a.bmp',count=n)
for i=0,n-1,1 do begin
print,query_bmp(files(i))
;im=read_bmp(files(i))
print,i
endfor
end