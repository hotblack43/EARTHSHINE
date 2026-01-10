


close,/all
nsims=10000
nyears=100
eta=0.0006
meanalbedo=0.3
openw,1,'data.dat'
x=findgen(n*365.)
slope=meanalbedo/100./(max(x)-min(x))
for isim=0,nsims-1,1 do begin
noise=randomn(seed,n)*eta
y=meanalbedo+slope*x+noise
print,robust_sigma(noise)/median(y)*100.,' % noise on each annual observation'
res=robust_linefit(X, Y, YFIT, SIG, COEF_SIG)
printf,1,res(1),robust_sigma(y-yfit)
endfor
close,1
print,'Slope: ',slope
data=get_data('data.dat')
histo,title='Slope',data(0,*),min(data(0,*)),max(data(0,*)),(max(data(0,*))-min(data(0,*)))/31.
print,median(data(0,*)),' +/- ',robust_sigma(data(0,*)),' Z= ',1./(robust_sigma(data(0,*))/median(data(0,*)))
print,median(data(1,*)),' is median annual noise, or ',robust_sigma(data(1,*))/0.3*100.,' % of median albedo'
end
