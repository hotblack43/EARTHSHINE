FUNCTION scramble,w_in
w=w_in
n=n_elements(w)
idx=randomu(seed,n)
jdx=sort(idx)
w=w(jdx)
return,w
end

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
r=fltarr(n_MC)
       iflag=1
       array1=reform(data(i,*))
       z=reform(data(j,*))
       r_obs=correlate(array1,z)
for itest=0,n_MC-1,1 do begin
       z=reform(data(j,*))
       array2=scramble(z)
       r(itest)=correlate(array1,array2)
endfor
       nbetter=n_elements(where(abs(r) gt abs(r_obs)))
       print,i,j,R_obs,100.-float(nbetter)/float(n_MC)*100.,' %'
endif
endfor
endfor
end
