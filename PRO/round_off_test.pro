; Evaluates the error due to roundoff when averaging
openw,12,'data.plt'
for number=5.0,40.,1 do begin
M=2000
xx=fltarr(M-2)
yy=fltarr(M-2)
yyy=fltarr(M-2)
zz=fltarr(M-2)
zzz=fltarr(M-2)
ww=fltarr(M-2)
www=fltarr(M-2)
i=0
for n=2.,M-1,1 do begin
z=randomu(seed,n,poisson=number,/double)
x=fix(z)
;print,(number-1.)/2.-mean(x),stddev(x),n
xx(i)=n
yy(i)=mean(x)
yyy(i)=mean(z)
zz(i)=stddev(x)/sqrt(n-1.)
zzz(i)=stddev(z)/sqrt(n-1.)
ww(i)=zz(i)/yy(i)*100.0
www(i)=zzz(i)/yyy(i)*100.0
i=i+1
endfor
!P.MULTI=[0,1,2]
plot,xx,yy,ystyle=1
oplot,xx,yy+zz,thick=3,color=255,nsum=11
oplot,xx,yy-zz,thick=3,color=255,nsum=11
plot_io,xx,ww,xtitle='N',ytitle='Uncertainty in %',charsize=2,nsum=11,yrange=[0.1,100],title='Pixel value:'+string(number)
oplot,[!X.crange],[1.0,1.0],linestyle=4
idx=where(ww le 1.0)
jdx=where(www le 1.0)
plots,[xx(idx(0)),xx(idx(0))],[0.1,100]
print,'Rounded off: 1% err at ',idx(0),' pixels.'
print,'Raw numbers: 1% err at ',jdx(0),' pixels.'
printf,12,number,idx(0),jdx(0)
endfor
close,12
; plot
!P.MULTI=[0,1,1]
data=get_data('data.plt')
x=reform(data(0,*))
y=reform(data(1,*))
z=reform(data(2,*))
idx=where(y ne 0)
plot,x(idx),y(idx),xtitle='Mean Poisson distributed flux count',ytitle='Number of pixels at 1% error.',charsize=2,xstyle=1,ystyle=1,title='Simulation, ideal case (dot-dashed)'
oplot,x(idx),z(idx)
oplot,x(idx),100.*100./x(idx),linestyle=4
end

