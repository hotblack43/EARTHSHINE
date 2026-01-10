path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455643/'
files=file_search(path+'*.f*t*',count=n)
for i=0,n-1,1 do begin
print,'Found file: ',files(i)
im2=readfits(files(i))
tvscl,im2
im=tvrd()
l=size(im,/dimensions)
stump=strmid(files(i),0,strpos(files(i),'.',/REVERSE_SEARCH))
name=strcompress(stump+'_inspected.jpeg',/remove_all)
if (n_elements(l) eq 3) then begin
write_jpeg,name,bytscl(reform(im(*,*,0)))
endif
if (n_elements(l) eq 2) then begin
write_jpeg,name,bytscl(im)
endif
endfor
end


