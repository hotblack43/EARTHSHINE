path='f:\16bits\\'
files=file_search(path,'*.TIFF',count=n)
a=1230
b=1919
c=1255
d=1600
get_lun,u
openw,u,'Exposures_1.dat'
fmt='(i3,6(1x,f9.3))'
for i=0,n-1,1 do begin
im=read_tiff(files(i))
print,format=fmt,i,mean(im(*,a:b,c:d)),mean(im(0,a:b,c:d)),mean(im(1,a:b,c:d)),mean(im(2,a:b,c:d))
printf,u,format=fmt,i,mean(im(*,a:b,c:d)),mean(im(0,a:b,c:d)),mean(im(1,a:b,c:d)),mean(im(2,a:b,c:d))
endfor
close,u
data=get_data('Exposures_1.dat')
number=reform(data(0,*))
mn_3=reform(data(1,*))
mn_0=reform(data(2,*))
mn_1=reform(data(3,*))
mn_2=reform(data(4,*))
;
!P.MULTI=[0,1,2]
plot,mn_3,xtitle='Exposure time (s)',ytitle='mean pixel counts',charsize=2,ystyle=1
print,'S.D: in pct of mean:',stddev(mn_3)/mean(mn_3)*100.0
end