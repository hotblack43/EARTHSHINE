FUNCTION GETNAM,str
arr=strsplit(str,'.',/EXTRACT)
arr=arr(n_elements(arr)-2)
arr=strsplit(arr,'/',/EXTRACT)
name=arr(n_elements(arr)-1)
GETNAM=strcompress('THUMBNAILS/'+name+'.jpg',/remove_all)
return,GETNAM
end

files=file_search('.','*.FIT')
n=n_elements(files)
for i=0,n-1,1 do begin
im=readfits(files(i))
l=size(im,/dimensions)
name=GETNAM(files(i))
print,files(i),name
writefits,name,rebin(im,l/4)
endfor
end
