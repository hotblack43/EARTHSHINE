n=512
openw,12,'512x512array.csv'
array=randomu(seed,n,n)*50000L
for i=0,n-1,1 do begin
;for j=0,n-1,1 do begin
printf,12,format=fmt,array(i,*)
;endfor
endfor
close,12
end
