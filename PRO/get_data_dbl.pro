FUNCTION get_data_dbl,filename
n=get_file_size(filename)
spawn,'wc '+filename+' > size'
openr,73,'size'
readf,73,nn,m
close,73
ncols=float(m)/float(nn)
if (ncols ne fix(ncols)) then stop
data=dblarr(ncols,n)
openr,78,filename
readf,78,data
close,78
get_data=data
return,get_data
end
