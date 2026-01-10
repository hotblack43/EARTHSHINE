PRO removealinearsurface,im,mask
mim=mask*im
get_lun,wxy
openw,wxy,'masked.dat'
for i=0,511,1 do begin
for j=0,511,1 do begin
if (mim(i,j) ne 0.0) then begin
printf,wxy,i,j,mim(i,j)
endif
endfor
endfor
close,wxy
free_lun,wxy
data=get_data('masked.dat')
res=sfit(data,/IRREGULAR,1)
for k=0,n_elements(res)-1,1 do begin
im(data(0,k),data(1,k))=im(data(0,k),data(1,k))-res(k)
endfor
return
end
