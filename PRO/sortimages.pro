path='~/Desktop/ASTRO/MOON/May27/obsrun1'
path='~/Desktop/ASTRO/MOON/May28/FLATS1'
path='~/Desktop/ASTRO/MOON/May29/Flats1'
files=file_search(path,'*.FIT')
n=n_elements(files)
for i=0,n-1,1 do begin
im=readfits(files(i))
l=size(im,/dimensions)
;tvscl,rebin(im,l/4)
plot,total(im,2),ystyle=1
type=''
print,max(im)
print,' R/L '
type=get_KBRD()
if (type eq 'R' or type eq 'r') then file_copy,files(i),path+'/RIGHT',/OVERWRITE
if (type eq 'L' or type eq 'l') then file_copy,files(i),path+'/LEFT',/OVERWRITE
endfor
end
