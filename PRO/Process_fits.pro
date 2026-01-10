
path='f:\'
dark_files=file_search(path,'dark*',count=n_dark)
flat_files=file_search(path,'flat*',count=n_flats)
;
info=file_info(path+'dark_2x2_final.fit')
if (info.exists ne 1) then begin
;  average the darks
for i=0,n_dark-1,1 do begin
im=readfits(dark_files(i))
if (i eq 0) then dark=double(im) else dark=dark+double(im)
endfor
dark=dark/float(n_dark)
writefits,path+'dark_2x2_final.fit',dark
print,'Darks processed.'
endif
if (info.exists eq 1) then dark=readfits(path+'dark_2x2_final.fit')
;  average the flats
info=file_info(path+'flat_2x2_final.fit')
if (info.exists ne 1) then begin
for i=0,n_flats-1,1 do begin
im=readfits(flat_files(i))
if (i eq 0) then flat=double(im-dark) else flat=flat+double(im-dark)
endfor
flat=flat/float(n_flats)
writefits,path+'flat_2x2_final.fit',flat
print,'Flats processed.'
endif
if (info.exists eq 1) then flat=readfits(path+'flat_2x2_final.fit')
; process real images..
imfilename=path+'im2.fit'
im=readfits(imfilename)
image=(double(im)-dark)/flat
writefits,'corrected.fit',image
print,' Image processed.'
end
