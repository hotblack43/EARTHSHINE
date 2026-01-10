path='/media/LaCie/ASTRO/ANDOR/USB2/'
files=file_search(path+'Dark*.fits',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i),h)
l=size(im)
print,l
endfor
end
