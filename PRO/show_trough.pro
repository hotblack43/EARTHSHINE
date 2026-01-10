


im=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456106/2456106.8160130MOON_B_AIR.fits.gz',h)
!P.multi=[0,1,2]
!P.charsize=2
!P.charthick=3
openw,44,'data.dat'
for k=0,99,1 do begin
;plot,avg(im(0:69,*,k),0),yrange=[390,402]
;oplot,avg(im(70:140,*,k),0),color=fsc_color('red')
;plot,avg(im(0:69,*,k),0)-avg(im(70:140,*,k),0),ystyle=3
line1=avg(im(0:140,*,k),0)
print,mean(avg(im(0:69,*,k),0))-mean(avg(im(70:140,*,k),0)),mean(line1(140:200))
printf,44,mean(avg(im(0:69,*,k),0))-mean(avg(im(70:140,*,k),0)),mean(line1(140:200))-mean(line1(0:130))
endfor
close,44
data=get_data('data.dat')
!P.multi=[0,1,2]
plot,yrange=[-0.6,0],data(1,*),xtitle='Image # in stack',ytitle='Trough depth'
res=robust_linefit(findgen(100),data(1,*),yhat,sig,sigs)
;yhat=res(0)+res(1)*findgen(100)
oplot,findgen(100),yhat,color=fsc_color('red'),thick=4
end
