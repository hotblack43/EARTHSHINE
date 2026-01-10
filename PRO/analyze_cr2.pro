; analysis of CR2 images converted to fits format with AstroArt
files=file_search('e:\Image*.fit',count=n)
help
openw,3,'cr2.dat'
for i=0,n-1,1 do begin
im=readfits(files(i))
r=im(811:3081,446:2037,0)
g=im(811:3081,446:2037,1)
b=im(811:3081,446:2037,2)
printf,3,mean(r,/double),stddev(r,/DOUBLE)^2
printf,3,mean(g,/double),stddev(g,/DOUBLE)^2
printf,3,mean(b,/double),stddev(b,/DOUBLE)^2
endfor
close,3
data=get_data('cr2.dat')
mn=reform(data(0,*))
vr=reform(data(1,*))
idx=sort(mn)
mn=mn(idx)
vr=vr(idx)
n=n_elements(mn)
mn=mn(0:n-4)
vr=vr(0:n-4)
idx=where(mn gt 1000)
mn=mn(idx)
vr=vr(idx)
n=n_elements(mn)
plot_oo,mn,vr,psym=7,xtitle='Mean',ytitle='Variance',title='Canon 350D CMOS chip'
res=linfit(alog10(mn),alog10(vr),/double,yfit=yhat)
oplot,mn,10^yhat,color=fsc_color('red')
oplot,mn,mn,color=fsc_color('blue')
print,res
end
