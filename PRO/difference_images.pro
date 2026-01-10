files=file_search('E:\Image*.JPG',count=n)
openw,2,'data.dat'
for i=0,n-1,2 do begin
; step 1
read_jpeg,files(i),im1
read_jpeg,files(i+1),im2
im1=reform(im1(1,*,*))
im2=reform(im2(1,*,*))
; skip step 2 bias almost 0
; step 3
mn1=mean(im1(1000:2000,500:1200),/double)
mn2=mean(im2(1000:2000,500:1200),/double)

; step 4
r=mn1/mn2
; step 5
im2=im2*r
; step 6
diff=im2-im1
; step 7
var=stddev(diff(1000:2000,500:1200),/double)^2/2.0
; step 8
printf,2,mn1,var
endfor
close,2
data=get_data('data.dat')
mn=reform(data(0,*))
var=reform(data(1,*))
plot,mn,var,psym=7,xtitle='Mean',ytitle='Variance'
end