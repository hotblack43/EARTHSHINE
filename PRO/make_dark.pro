files=file_search('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON','dark*.*')
print,files
n=n_elements(files)
for i=0,n-1,1 do begin
    im=readfits(files(i))
    if(i eq 0) then stack=im
    if(i gt 0) then stack=[[[stack]],[[im]]]

endfor
superdark=median(stack,dimension=3)
surface,superdark,zrange=[900,1200],charsize=2
writefits,'dark.fit',superdark
end
