;files=file_search('\\Dadslaptop\my documents\series_light2_*.fit',count=n)
files=file_search('\\Dadslaptop\my documents\NoName*.fit',count=n)
ref=readfits(files(0))
l=size(ref,/dimensions)
files=files(3:9)
n=n_elements(files)
mn=fltarr(n)
var=fltarr(n)
ref=rebin(ref,l(0)/2.,l(1)/2)
for i=0,n-1,1 do begin
im=readfits(files(i))-ref
im=rebin(im,l(0)/2.,l(1)/2)
idx=where( im lt 65000)
mn(i)=mean(im(idx),/double)
var(i)=stddev(im(idx),/double)^2
endfor
plot_oo,mn,var,psym=7,xtitle='Mean',$
ytitle='Variance',charsize=2,xstyle=1,ystyle=1,$
xrange=[100,40000],yrange=[100,9e7]
jdx=where(mn gt 100)
res=linfit(alog10(mn(jdx)),alog10(var(jdx)),/double,yfit=yhat,sigma=sigs)
print,res,sigs
oplot,mn(jdx),10^yhat,color=fsc_color('red')
oplot,mn(jdx),mn(jdx),color=fsc_color('blue')
end
