read_jpeg,'moon1170404522.jpg',im
help,im
openw,11,'basemap.dat'
l=size(im,/dimensions)
ncols=l(0)
nrows=l(1)
for i=0,nrows-1,1 do begin
printf,format=strcompress('('+string(ncols)+'(i4))',/remove_all),11,im(*,i)
endfor
close,11
end
