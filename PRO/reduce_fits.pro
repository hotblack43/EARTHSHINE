Iswitch=1	; 1 is median 2 is average
; get the super flat field
files=file_search('OUTPUT/flat_*.fit')
n=n_elements(files)
for i=0,min([n-1,30]),1 do begin
	print,i
	im=readfits(files(i),header)
	if (i eq 0) then sum=im
	if (i gt 0) then sum=[[[sum]],[[im]]]
endfor
if (iswitch eq 1) then flat=median(sum,dimension=3)
if (iswitch eq 2) then flat=total(sum,3)/float(n)
flat=flat/mean(flat,/double)
; get the super dark frame
files=file_search('OUTPUT/darkframe_*.fit')
n=n_elements(files)
for i=0,min([n-1,10]),1 do begin
	print,i
	im=readfits(files(i),header)
	if (i eq 0) then sum=im
	if (i gt 0) then sum=[[[sum]],[[im]]]
endfor
if (iswitch eq 1) then dark=median(sum,dimension=3)
if (iswitch eq 2) then dark=total(sum,3)/float(n)
; find all files to reduce
files=file_search('OUTPUT/LunarImg_*.fit')
n=n_elements(files)
for i=0,n-1,1 do begin
	print,i,'   ',files(i)
	im=readfits(files(i),header)
	sxaddpar, header, 'HISTORY','Dark frame subtracted, then division by flatfield'
	writefits,strcompress('OUTPUT/'+files(i),/remove_all),float((im-dark)/flat),header
endfor
end
