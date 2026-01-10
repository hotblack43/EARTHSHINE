files=file_search('/data/pth/DATA/ANDOR/temp/*DARK*.fits',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i))
if (i eq 0) then stack=im
if (i gt 0) then stack=[[[stack]],[[im]]]
endfor
bias=avg(stack,2)
writefits,strcompress('DAVE_BIAS.fits',/remove_all),bias
end
