files=file_search('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\testimages','pointOne*.fit')
nfiles=n_elements(files)
im0=double(readfits(files(0)))
for i=1,nfiles-1,1 do begin

im=double(readfits(files(i)))

im0=[[[im0]],[[im]]]

endfor
dark1=total(im0,3)/float(nfiles)
;
files=file_search('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\testimages','pointTwo*.fit')
nfiles=n_elements(files)
im0=double(readfits(files(0)))
for i=1,nfiles-1,1 do begin

im=double(readfits(files(i)))
im0=[[[im0]],[[im]]]

endfor
dark2=total(im0,3)/float(nfiles)

bias=2*dark1-dark2
end