files=file_search('D:\','*.fit')
n=n_elements(files)
for i=0,n-1,1 do begin
im=readfits(files(i))
im=im(290:419,369:484)
name=strcompress(strmid(files(i),3,strlen(files(i))-4-3)+'_clip.fit',/remove_all)
print,name
writefits,name,im
endfor
end