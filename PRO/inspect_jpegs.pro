path='C:\Documents and Settings\Peter Thejll\My Documents\My Pictures\'
files=file_search(path,'*.JPG',count=n)
;files=files(0:59)
n=n_elements(files)
a=969
b=1311
c=558
d=806
get_lun,u
openw,u,'Exposures_1.dat'
fmt='(i3,6(1x,f9.3))'
for i=0,n-1,1 do begin
exif_reader,files(i),values
read_jpeg,files(i),im
print,format=fmt,i,mean(im(*,a:b,c:d)),mean(im(0,a:b,c:d)),mean(im(1,a:b,c:d)),mean(im(2,a:b,c:d)),values.shutter,values.fnum
printf,u,format=fmt,i,mean(im(*,a:b,c:d)),mean(im(0,a:b,c:d)),mean(im(1,a:b,c:d)),mean(im(2,a:b,c:d)),values.shutter,values.fnum
endfor
close,u
data=get_data('Exposures_1.dat')
number=reform(data(0,*))
mn_3=reform(data(1,*))
mn_0=reform(data(2,*))
mn_1=reform(data(3,*))
mn_2=reform(data(4,*))
exposure=1./reform(data(5,*))
fnum=reform(data(6,*))
;
!P.MULTI=[0,1,3]
; get the unique fnumbers
uniq_f=fnum(uniq(fnum(sort(fnum))))
n_uniq=n_elements(uniq_f)
for ifnum=0,n_uniq-1,1 do begin
idx=where(fnum eq uniq_f(ifnum))
plot,exposure(idx),mn_3(idx),psym=7,xtitle='Exposure time',ytitle='Mean pixel value in a square',charsize=2,title='f/'+string(uniq_f(ifnum))
endfor
end