; run do_sex
; cat test.cat's > all
; get rid of text lines
openw,3,'matches.dat'
file='all'
d_limit=1.5
data=get_data(file)
;         13  -4.8034   0.2878     459.3899     67.175    454.134   0
number=reform(data(0,*))
mag=reform(data(1,*))
err_mag=reform(data(2,*))
backg=reform(data(3,*))
x=reform(data(4,*))
y=reform(data(5,*))
n=n_elements(x)
for i=0,n-2,1 do begin
for j=i,n-1,1 do begin
d=sqrt((x(i)-x(j))^2+(y(i)-y(j))^2)
if (d lt d_limit) then print,i,mag(j),err_mag(j)
if (d lt d_limit) then printf,3,i,mag(j),err_mag(j)
endfor
endfor
close,3
;
file='matches.dat'
data=get_data(file)
num=reform(data(0,*))
mag=reform(data(1,*))
err=reform(data(2,*))
au=num(sort(num))
uniqnum=num(uniq(au))
openw,4,'magsetc.dat'
for i=0,n_elements(uniqnum)-1,1 do begin
idx=where(num eq uniqnum(i))
if (n_elements(idx) gt 2) then print,mean(mag(idx)),stddev(mag(idx)),mean(err(idx))
if (n_elements(idx) gt 2) then printf,4,mean(mag(idx)),stddev(mag(idx)),mean(err(idx))
endfor
close,4
;
data=get_data('magsetc.dat')
mag=reform(data(0,*))
SD=reform(data(1,*))
meanerr=reform(data(2,*))
plot,mag,SD,psym=7,xtitle='Magnitude',ytitle='SD and mean sigma (red)',charsize=2
oplot,mag,meanerr,psym=7,color=fsc_color('red')
end
