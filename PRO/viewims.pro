files=file_search('MOON/May27/FR_MOON/','*.FIT')
nims=n_elements(files)
for ifile=0,nims-1,1 do begin
        im=readfits(files(ifile),header)
        tvscl,im
	print,'Image ',ifile
	read,a
endfor
end
