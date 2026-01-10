FUNCTION get_file_size,file
rnd_filename,size_filename
aha = 'wc '+file+' > '+size_filename
spawn,/SH,aha
n=0L
openr,luin,size_filename,/get_lun
readf,luin,n
close,luin
free_lun,luin
aha = 'rm '+size_filename
spawn,/SH, aha
get_file_size=n
return,get_file_size
end
