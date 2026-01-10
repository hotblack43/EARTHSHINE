file='15x6matrx.txt'
data=get_data(file)
help,data
l=size(data,/dimensions)
ncols=l(0)
nrows=l(1)
for i=0,ncols-1,1 do begin
for j=i,ncols-1,1 do begin
if (i ne j) then begin
n_MC=10000
       iflag=1
       array2=reform(data(i,*))
       array1=reform(data(j,*))
       mc_correlate,array1,array2,MC_siglevel,n_MC,R,iflag
       print,i,j,R,100.-MC_siglevel
endif
endfor
endfor
end
