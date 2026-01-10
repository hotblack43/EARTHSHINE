files=file_search('out*.fits',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i))
x=randomn(seed)*10.0
y=randomn(seed)*10.0
writefits,strcompress('SHIFTED_'+files(i),/remove_all),shift(im,x,y)
endfor
end
