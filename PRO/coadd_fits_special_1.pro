dark=readfits('average_60s_dark_2455719.fit')
;
path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455719/'
files=file_search(path+'2455719.7883284MoonCoAdd.fits',count=n)
;files=file_search(path+'2455719.7876739MoonCoAdd.fits',count=n)
	heap=double(readfits(files))
	help,heap
!P.MULTI=[0,1,1]
l=size(heap,/dimensions)
n=l(2)
for i=0,n-1,1 do begin
	im=heap(*,*,i)-dark
	if (i eq 0) then stack=im
	if (i gt 0) then stack=[[[stack]],[[im]]]
endfor
help,stack
median_image=median(stack,dimension=3)
average_image=AVG(stack,2)
  MKHDR, header, median_image
oldheader=header
  sxaddpar, header, 'EXPLAIN', 0, 'This is the median of the stacked images'
  writefits, 'median_dark_subtracted_coadded_2455719.fit', median_image, header
  sxaddpar, oldheader, 'EXPLAIN', 0, 'This is an average of the stacked images'
  writefits, 'average_dark_subtracted_coadded_2455719.fit.fit', average_image, oldheader
end
