;files=file_search('\\Dadslaptop\my documents\series_light2_*.fit',count=n)
files=file_search('\\Dadslaptop\my documents\darklight2*.fit',count=n)

for i=0,n-1,1 do begin
print,i
im=readfits(files(i))
if (i eq 0) then stack=im
if (i gt 0) then stack=[[[stack]],[[im]]]
endfor
l=size(im,/dimensions)
;save,stack,filename='stack.sav'
save,stack,filename='darkstack.sav'
end