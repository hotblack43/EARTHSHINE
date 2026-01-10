bias=readfits('TTAURI/superbias.fits')
bias=bias*0.0
;im=double(readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456073/2456073.7781942MOON_V_AIR.fits.gz'))
im=double(readfits('stack_2455945.1776847_alf_1p5_alb_0p31.fits'))
;im=im*1.6543d0
;im=im/3.78
l=size(im,/dimensions)
n=l(2)
openw,33,'vars.dat'
sc=1
im=rebin(im,512/sc,512/sc,l(2))

w=512/2/sc
x0=346.84724/sc       
y0=295.10121/sc

xlo=x0-w/2
xhi=x0+w/2
ylo=y0-w/2
yhi=y0+w/2
for i=xlo,xhi,1 do begin
print,i
for j=ylo,yhi,1 do begin
biasrow=dindgen(l(2))*0.0+bias(i,j)
printf,33,mean(im(i,j,*)-biasrow),stddev(im(i,j,*))
endfor
endfor
close,33
data=get_data('vars.dat')
plot_oo,xrange=[0.01,1e5],yrange=[0.01,1e5],data(0,*),data(1,*)^2,xtitle='Mean',ytitle='Var',psym=3,/isotropic
;oplot,[1,10000],[1,10000]

end
