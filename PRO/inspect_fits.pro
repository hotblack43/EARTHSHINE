path='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\movie\'
files=file_search(path,'M31*.fit',count=n)
print,'Found:',n,' fits files.'
get_lun,unit
a=82 & b=358 & c=104 & d=235
openw,unit,'data.dat'
for i=0,n-1,1 do begin
im=readfits(files(i))
print,i,mean(im(a:b,c:d))
printf,unit,i,mean(im(a:b,c:d))
endfor
close,unit
free_lun,unit
;........
data=get_data('data.dat')
mn=reform(data(1,*))
idx=where(mn lt 4.83e4)
mn=mn(idx)
plot,mn,ystyle=1
print,mean(mn),stddev(mn)/mean(mn)*100.0,' %'
end