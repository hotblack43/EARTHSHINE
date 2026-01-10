file='C:\Documents and Settings\Peter Thejll\Desktop\Lydfiler\sliding.wav'
res=float(read_wav(file,rate))
print,'Rate=',rate
!P.MULTI=[0,1,3]
n=n_elements(res(0,*))
print,n
idx=dindgen(n)
i1=50000L
i2=350000L
left=reform(res(0,idx(i1:i2)))
right=reform(res(1,idx(i1:i2)) )
n=n_elements(left)
width=200
for i=0L,n-1-width,width do begin
left_bit=left(i:i+width)
right_bit=right(i:i+width)
;plot,left_bit
;oplot,right_bit,thick=3
array=(c_correlate(left_bit,right_bit,indgen(width)-width/2.))
plot,array
idx=where(array eq max(array))
if (i eq 0) then y=idx(0)
if (i gt 0) then y=[y,idx(0)]
endfor
y=y-width/2.
plot,y,ystyle=1,psym=7
end