files=file_search('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\','img*.fit')
n=n_elements(files)
openw,11,'IMG_FIT.list'
for i=0,n-1,1 do begin
Result = READFITS(files(i), Header)
printf,11,format='(a,1x,a,1x,a)',files(i),header(10),header(11)
endfor
close,11
end