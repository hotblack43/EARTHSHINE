path='~/Desktop/ASTRO/MOON/May25/May25/'
file='IMG*'
files=file_search(path,file)
nfiles=n_elements(files)
factor=4
for i=0,nfiles-1,1 do begin
	im=readfits(files(i))
	l=size(im,/dimensions)
	im=rebin(im,l(0)/factor,l(1)/factor)
	tvscl,im
	pos1=strpos(files(i),'IMG')
	pos2=strpos(files(i),'.FIT')
;	print,strmid(files(i),pos1+3,pos2-pos1-3)
 	number=fix(strmid(files(i),pos1+3,pos2-pos1-3))
 	;filename=strcompress(path+'JPG/IMG'+string(number)+'.jpg',/remove_all)
 	;write_jpeg,filename,im
 	filename=strcompress(path+'JPG/IMG'+string(number)+'.bmp',/remove_all)
	r = BYTSCL(INDGEN(16)) 
	WRITE_BMP, filename, BYTSCL(Im, MAX=15), r, r, r, /FOUR
endfor
end

