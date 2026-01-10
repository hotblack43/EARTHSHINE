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

!P.MULTI=[0,3,4]
!P.CHARSIZE=2
 common sizes,l
;bias1=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1689651DARK_DARK.fits.gz')
;im=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1684459MOON_V_AIR.fits.gz')
;bias2=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1687603DARK_DARK.fits.gz')
bias1=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1764911DARK_DARK.fits.gz')
im=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1776847MOON_V_AIR.fits.gz')
bias2=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1784142DARK_DARK.fits.gz')
print,'mhm of bias1 and bias2: ',mhm((bias1+bias2)/2.0d0)
bias=readfits('superbias.fits')
print,'mhm of superbias: ',mhm(bias)
factor=mhm((bias1+bias2)/2.0d0)/mhm(bias)
print,'Factor on superbias should be: ',factor
bias=bias*factor
openw,33,'p.dat'
l=size(im,/dimensions)
nn=l(2)
;window,2,xsize=512,ysize=512
for i=1,nn-1,1 do begin
subim=reform(im(*,*,i))
print,mean(subim)
tot=total(subim,/double)
idx=where(subim gt 1000)
get_mask,194.,286.,146.,mask
jdx=where(subim le 410 and mask ne 0)
bs=total(subim(idx),/double)
ds=total(subim(jdx),/double)
; now remove bias and use same idx's
ss=subim-bias
tot2=total(ss,/double)
bs2=total(ss(idx),/double)
ds2=total(ss(jdx),/double)
; and now find and remove alinear surafce fitte dto the corners
findafittedlinearsurface,ss,thesurface
sss=ss-thesurface
;tvscl,hist_equal(sss)
tot3=total(sss,/double)
bs3=total(sss(idx),/double)
ds3=total(sss(jdx),/double)
; normalize with the BS flux
ssss=sss/bs3
tot4=total(ssss,/double)
bs4=total(ssss(idx),/double)
ds4=total(ssss(jdx),/double)
printf,format='(i3,12(1x,f20.10))',33,i,tot,bs,ds,tot2,bs2,ds2,tot3,bs3,ds3,tot4,bs4,ds4
endfor
close,33
;
data=get_data('p.dat')
ser=reform(data(0,*))
tot=reform(data(1,*))
bs=reform(data(2,*))
ds=reform(data(3,*))
tot2=reform(data(4,*))
bs2=reform(data(5,*))
ds2=reform(data(6,*))
tot3=reform(data(7,*))
bs3=reform(data(8,*))
ds3=reform(data(9,*))
tot4=reform(data(10,*))
bs4=reform(data(11,*))
ds4=reform(data(12,*))
;window,0
plot,ser,tot,ystyle=3,ytitle='total',title='No bias subtracted'
goplotline,ser,tot
plot,ser,bs,ystyle=3,ytitle='BS',title='No bias subtracted'
goplotline,ser,bs
plot,ser,ds,ystyle=3,ytitle='DS',title='No bias subtracted'
goplotline,ser,ds
plot,ser,tot2,ystyle=3,ytitle='total',title='bias subtracted'
goplotline,ser,tot2
plot,ser,bs2,ystyle=3,ytitle='BS',title='bias subtracted'
goplotline,ser,bs2
plot,ser,ds2,ystyle=3,ytitle='DS',title='bias subtracted'
goplotline,ser,ds2
plot,ser,tot3,ystyle=3,ytitle='total',title='bias + surface subtracted'
goplotline,ser,tot3
plot,ser,bs3,ystyle=3,ytitle='BS',title='bias + surface subtracted'
goplotline,ser,bs3
plot,ser,ds3,ystyle=3,ytitle='DS',title='bias +sufrace subtracted'
goplotline,ser,ds3
plot,ser,tot4,ystyle=3,ytitle='total',title='above/(bs above)'
goplotline,ser,tot4
plot,ser,bs4,ystyle=3,ytitle='BS',title='above/(bs above)'
goplotline,ser,bs4
plot,ser,ds4,ystyle=3,ytitle='DS',title='above/(bs above)'
goplotline,ser,ds4
end
