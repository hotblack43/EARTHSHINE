files=file_search('200th\*.jpg',count=n)
for i=0,n-1,1 do begin
read_jpeg,files(i),im
im=total(im,1)
if (i eq 0) then stack=im
if (i gt 0) then stack=[[[stack]],[[im]]]
help,stack
endfor
im=total(stack,3)/float(n)
writefits,'200th.fit',im
end

