files=file_search('PEN/*',count=n)
openw,33,'sharpness.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),/sil)
print,max(abs(im-shift(im,0,1))),max(abs(im-shift(im,1,0))),files(i)
printf,33,format='(f10.2,1x,a)',sqrt(max(abs(im-shift(im,0,1)))^2+max(abs(im-shift(im,1,0)))^2),files(i)
endfor
close,33
end
