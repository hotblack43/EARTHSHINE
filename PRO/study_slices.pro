 PRO get_mask,x0,y0,radius,mask
 ; build a 1/0 mask that is a circle (center x0,y0) and radius r with 0's outside radius and 1's inside
 common sizes,l
 nx=l(0) & ny=l(1) & mask=fltarr(nx,ny)
 for i=0,nx-1,1 do begin
     for j=0,ny-1,1 do begin
         rad=sqrt((i-x0)^2+(j-y0)^2)
         if (rad ge radius) then mask (i,j)=0 else mask(i,j)=1.0
         endfor
     endfor
 return
 end

FUNCTION mhm,array_in
array=array_in(sort(array_in))
n=n_elements(array)
array=array(n*.25:n*.75)
mhm=avg(array,/double)
return,mhm
end

PRO findafittedlinearsurface,im,thesurface
l=size(im,/dimensions)
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
;----------------------------------------
w=15
xll=mhm(x(0:w,*))
xlr=mhm(x(512-w:511,*))
xul=xll
xur=xlr
yll=mhm(y(*,0:w))
ylr=yll
yul=mhm(y(*,512-w:511))
yur=yul
zll=mhm(im(0:w,0:w))
zlr=mhm(im(512-w:511,0:w))
zul=mhm(im(0:w,512-w:511))
zur=mhm(im(512-w:511,512-w:511))
openw,55,'masked.dat'
printf,55,xll,yll,zll
printf,55,xul,yul,zul
printf,55,xlr,ylr,zlr
printf,55,xur,yur,zur
close,55
data=get_data('masked.dat')
res=sfit(data,/IRREGULAR,1,kx=coeffs)
thesurface=coeffs(0,0)+coeffs(1,0)*y+coeffs(0,1)*x+coeffs(1,1)*x*y
return
end

PRO goplotline,x,y
n=n_elements(x)
!P.CHARSIZE=2
res=linfit(x,y,/double,yfit=yhat)
print,'Slope: ',(yhat(n-1)-yhat(0))/mhm(yhat)*100.,' %.'
oplot,x,yhat,color=fsc_color('red')
xyouts,charsize=1.4,/data,5,(!Y.crange(1)-!Y.crange(0))*0.85+!Y.crange(0),' Slope: '+string((yhat(n-1)-yhat(0))/mhm(yhat)*100.,format='(f7.2)')+' %'
return
end

!P.MULTI=[0,3,1]
!P.CHARSIZE=2
 common sizes,l
;bias1=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1689651DARK_DARK.fits.gz')
;im=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1684459MOON_V_AIR.fits.gz')
;bias2=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1687603DARK_DARK.fits.gz')
bias1=double(readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1764911DARK_DARK.fits.gz'))
im=double(readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1776847MOON_V_AIR.fits.gz'))
bias2=double(readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1784142DARK_DARK.fits.gz'))
x0=194 & y0=286 & radius=146
;
bias=double(readfits('superbias.fits'))
factor=mhm((bias1+bias2)/2.0d0)/mhm(bias)
print,'Factor on superbias should be: ',factor
bias=bias*factor
l=size(im,/dimensions)
nn=l(2)
ic=0
for i=1,nn-1,1 do begin
subim=reform(im(*,*,i))
subim_minus_bias=subim-bias
findafittedlinearsurface,subim_minus_bias,thesurface
subim_minus_bias_minus_fittedsurface=subim_minus_bias-thesurface
if (ic eq 0) then begin
subim_cube=subim
subim_minus_bias_cube=subim_minus_bias
subim_minus_bias_minus_fittedsurface_cube=subim_minus_bias_minus_fittedsurface
endif
if (ic gt 0) then begin
subim_cube=[[[subim_cube]],[[subim]]]
subim_minus_bias_cube=[[[subim_minus_bias_cube]],[[subim_minus_bias]]]
subim_minus_bias_minus_fittedsurface_cube=[[[subim_minus_bias_minus_fittedsurface_cube]],[[subim_minus_bias_minus_fittedsurface]]]
endif
ic=ic+1
help,subim_cube
endfor
; convert to mags
subim_cube=-2.5*alog10(subim_cube)
subim_minus_bias_cube=-2.5*alog10(subim_minus_bias_cube)
subim_minus_bias_minus_fittedsurface_cube=-2.5*alog10(subim_minus_bias_minus_fittedsurface_cube)
; plot slices for movie making
w=25
for i=1,nn-1,1 do begin
d=subim_cube(*,y0-w:y0+w,nn/2)-subim_cube(*,y0-w:y0+w,i)
plot,yrange=[-0.2,0.2],avg(d,1),xstyle=3,ystyle=1,title='0-th image minus i-th image',ytitle='Magnitude diff.'
oplot,[x0-radius,x0-radius],[!Y.crange],linestyle=2
oplot,[x0+radius,x0+radius],[!Y.crange],linestyle=2
d=subim_minus_bias_cube(*,y0-w:y0+w,nn/2)-subim_minus_bias_cube(*,y0-w:y0+w,i)
plot,yrange=[-0.2,0.2],avg(d,1),xstyle=3,ystyle=1,title='Bias removed; 0-th image minus i-th image',ytitle='Magnitude diff.'
oplot,[x0-radius,x0-radius],[!Y.crange],linestyle=2
oplot,[x0+radius,x0+radius],[!Y.crange],linestyle=2
d=subim_minus_bias_minus_fittedsurface_cube(*,y0-w:y0+w,nn/2)-subim_minus_bias_minus_fittedsurface_cube(*,y0-w:y0+w,i)
plot,yrange=[-0.2,0.2],avg(d,1),xstyle=3,ystyle=1,title='Bias+FS removed; 0-th image minus i-th image',ytitle='Magnitude diff.'
oplot,[x0-radius,x0-radius],[!Y.crange],linestyle=2
oplot,[x0+radius,x0+radius],[!Y.crange],linestyle=2
;
writefits,strcompress('image_'+string(1000+i)+'.jpg',/remove_all),tvrd()
endfor
end
