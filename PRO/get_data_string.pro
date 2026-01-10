FUNCTION get_data_string,filename
n=get_file_size(filename)
rnd_filename,size_filename
spawn,'wc '+filename+' > '+size_filename
get_lun,uuu
openr,uuu,size_filename
nn=0L
m=0L
readf,uuu,nn,m
close,uuu
free_lun,uuu
ncols=double(m)/double(nn)
if (ncols ne fix(ncols)) then begin
	print,ncols,fix(ncols),' while reading ',filename
	print,' check out the file "size_filename"'
	spawn,' cat '+size_filename
	stop
endif
data=strarr(ncols,n)
get_lun,uuu
openr,uuu,filename
readf,uuu,data
close,uuu
free_lun,uuu
get_data=data
spawn,'rm '+size_filename
return,get_data
end
