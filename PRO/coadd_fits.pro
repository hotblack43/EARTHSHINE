path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455719/'
files=file_search(path+'2455719.8715391DARK_Dark_60s.fits',count=n)
!P.MULTI=[0,1,1]
for i=0,n-1,1 do begin
	print,i,files(i)
	im=double(readfits(files(i)))
	if (i eq 0) then stack=im
	if (i gt 0) then stack=[[[stack]],[[im]]]
endfor
median_image=median(stack,dimension=3)
average_image=AVG(stack,2)
  MKHDR, header, median_image
oldheader=header
  sxaddpar, header, 'EXPLAIN', 0, 'This is the median of the stacked images'
  writefits, 'median_60s_dark_2455719.fit', median_image, header
  sxaddpar, oldheader, 'EXPLAIN', 0, 'This is an average of the stacked images'
  writefits, 'average_60s_dark_2455719.fit', average_image, oldheader
end
