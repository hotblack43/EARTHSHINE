PRO get_firstname,file,firstname
; will return the part of a filename that preceedes the LAST dot in the filename
; and comes AFTER the LAST / in the filename (i.e. the name includes the path)
idx=STRPOS( file, '.', /REVERSE_SEARCH ) 
firstname=strmid(file,0,idx)
idx=STRPOS( firstname, '/', /REVERSE_SEARCH ) 
firstname=strmid(firstname,idx+1,strlen(firstname)-idx-1)
return
end

; Code to write out JPEG summary images from a set of FITS files
;
path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455481/'
spawn,'mkdir '+strcompress(path+'JPEG/',/remove_all)
names=strcompress(path+'*.fits',/remove_all)
files=file_search(names,count=n)
help,files
for i=0,n-1,1 do begin
	get_firstname,files(i),firstname
	jpegname=strcompress(path+'JPEG/'+firstname+'.jpg',/remove_all)	
	im=double(readfits(files(i)))
	l=size(im)
	print,i,files(i),l(0)
	if (l(0) eq 2) then begin
; it is a single image in a FITS file
	write_jpeg,jpegname,bytscl(im)
	endif
	if (l(0) eq 3) then begin
; it is a stack of images in a FITS file
	write_jpeg,jpegname,bytscl(im(*,*,0))
	endif
endfor
end
