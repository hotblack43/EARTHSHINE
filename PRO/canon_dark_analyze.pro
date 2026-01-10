files=file_search('I:\ASTRO\CANON_darks\Set1\*.tif',count=n)
fieldnum=0
fieldname=['R','G','B']
im=read_tiff(files(fieldnum))
im=double(reform(im(fieldnum,*,*)))
sum=im
for i=1,n-1,1 do begin
im=read_tiff(files(i))
im=double(reform(im(0,*,*)))
sum=sum+double(im)
print,mean(sum/float(i+1)),stddev(sum/float(i+1)),i
endfor
; fixed-pattern frame is now defined
fixed=sum/float(n)
; now redo, subtracting the fixed fgrame and study decay of error
openw,3,'data.dat'
im=read_tiff(files(0))
im=double(reform(im(0,*,*)))
sum=im-fixed
for i=1,n-1,1 do begin
im=read_tiff(files(i))
im=double(reform(im(0,*,*)))-fixed
sum=sum+double(im)
print,mean(sum/float(i+1)),stddev(sum/float(i+1)),i
printf,3,mean(sum/float(i+1)),stddev(sum/float(i+1)),i
endfor
close,3
;
!P.MULTI=[0,1,2]
data=get_data('data.dat')
means=reform(data(0,*))
stdd=reform(data(1,*))
numb=reform(data(2,*))
plot,numb,stdd,xtitle='Image #',ytitle='S.D. of im - F.P.',title=fieldname(fieldnum)
plot,numb,means,xtitle='Image #',ytitle='mean of im - F.P.'
plots,[!X.CRANGE],[0,0],linestyle=2
writefits,strcompress('Canon_flat_'+string(fieldname(fieldnum))+'.fit',/remove_all),fixed

end
