PRO gofindquartiles,arr_in,q1,q2,q3
 arr=arr_in(sort(arr_in))
 n=n_elements(arr)
 q1=arr(n*0.1)
 q2=arr(n*0.50)
 q3=arr(n*0.9)
 return
 end

!P.MULTI=[0,2,3]
openr,1,'Chris_list_good_images.txt'
openw,33,'stability_check.txt'
openw,34,'stability_check_nofilenames.txt'
while not eof(1) do begin
str=''
readf,1,str
file=file_search('/data/pth/DATA/ANDOR/MOONDROPBOX/','*'+str+'*',count=n)
print,n,file
if (n ne 1) then printf,33,format='(i4,1x,a)',n,str
if (n eq 1) then begin
im=readfits(file)
l=size(im,/dimensions)
nims=l(2)
arr=[]
for k=0,nims-1,1 do begin
arr=[arr,total(im(*,*,k))]
endfor
imnum=findgen(n_elements(arr))
plot,imnum,arr,title=file,ystyle=3,xstyle=3
gofindquartiles,arr,q1,q2,q3
oplot,[!X.crange(0),!X.crange(1)],[q1,q1],linestyle=2
oplot,[!X.crange(0),!X.crange(1)],[q3,q3],linestyle=2
;idx=where(arr gt q3 or arr lt q1)
idx=where(abs(arr-median(arr)) gt 3.*robust_sigma(arr))
jdx=where(abs(arr-median(arr)) le 3.*robust_sigma(arr))
if (idx(0) ne -1) then oplot,imnum(idx),arr(idx),psym=7,color=fsc_color('red')
print,stddev(arr)/median(arr)
print,stddev(arr(jdx))/median(arr(jdx)),' after remmmoving outliers.'
xarr=findgen(l(2))
res=ladfit(xarr,arr)
yhat=res(0)+res(1)*xarr
residuals=arr-yhat
oplot,xarr,yhat,color=fsc_color('red')
xyouts,10,2.*(!Y.crange(1)-!Y.crange(0))/10.+!Y.crange(0),'SD/mean='+string(stddev(residuals)/median(arr),format='(f9.5)')
;-------------
; now the jdx'd points
res2=ladfit(xarr(jdx),arr(jdx))
yhat2=res2(0)+res2(1)*xarr(jdx)
residuals2=arr(jdx)-yhat2
oplot,xarr(jdx),yhat2,color=fsc_color('green')
xyouts,10,1.*(!Y.crange(1)-!Y.crange(0))/10.+!Y.crange(0),'SD/mean='+string(stddev(residuals2)/median(arr(jdx)),format='(f9.5)')+' after outlier-removal'
;-------------
; the FFT spectrum
z=fft(arr-mean(arr),-1)
zz=double(z*conj(z))
plot,zz
if (total(zz(0:25)) lt total(zz(26:49))) then print,'Diminated by high frequencies'
if (total(zz(0:25)) ge total(zz(26:49))) then print,'Diminated by low frequencies'
if (zz(50)+zz(49)+zz(50) gt 4.*mean(zz(10:40))) then begin
	print,'Bimodal!'
	xyouts,10,3.*(!Y.crange(1)-!Y.crange(0))/10.+!Y.crange(0),'Bimodal flag!'
endif
;-------------
printf,33,format='(2(f9.5,1x,f9.1,1x),a)',stddev(residuals)/median(arr),res(1),stddev(residuals2)/median(arr(jdx)),res2(1),file
printf,34,format='(2(f9.5,1x,f9.1,1x))  ',stddev(residuals)/median(arr),res(1),stddev(residuals2)/median(arr(jdx)),res2(1)
endif
;a=get_kbrd()
endwhile
close,1
close,33
close,34
data=get_data('stability_check_nofilenames.txt')
relSD=reform(data(0,*))
slope=reform(data(1,*))
!P.MULTI=[0,1,3]
plot,relSD,slope,psym=7,xtitle='Relative SD',ytitle='Slope of total flux wrt im #',title='Check image stack stability',charsize=2,xstyle=3,ystyle=3
histo,/abs,xtitle='SD relative to mean',relSD,min(relSD),max(relSD),(max(relSD)-min(relSD))/73.
histo,/abs,xtitle='slope vs image #',slope,min(slope),max(slope),(max(slope)-min(slope))/73.
end
