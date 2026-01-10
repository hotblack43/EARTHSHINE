PRO spinit,subim,radius,spun
; spin subim around centre pixel and return radius,averaged profile
l=size(subim,/dimensions)
r=dblarr(l(0),l(1))
x0=l(0)/2.
y0=l(1)/2.
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
r(i,j)=sqrt((i-x0)^2+(j-y0)^2)
endfor
endfor
openw,33,'Profile.dat'
for rr=1,l(0)/2.*0.9,1 do begin
idx=where(r ge rr and r lt rr+1)
printf,33,(144.*(rr+0.5))/3600.,median(subim(idx))
endfor
close,33
data=get_data('Profile.dat')
radius=reform(data(0,*))
spun=reform(data(1,*))
return
end


im=readfits('~/Desktop/orion_field.fits',h)
w=200
!P.MULTI=[0,1,2]
!P.CHARSIZE=1.3
!P.THICK=4
!x.THICK=3
!y.THICK=3
!P.CHARthick=2
for  icol=1,3,1 do begin
subim=reform(im(*,*,icol-1))
if (icol eq 1) then subim=subim-40.
if (icol eq 2) then subim=subim-25.
if (icol eq 3) then subim=subim-20.
subim=subim(1489-w:1489+w,258-w:258+w)
spinit,subim,radius,spun
if (icol eq 1) then plot_oo,title='Moon halo from stock DSLR image',xrange=[0.1,10],yrange=[1,300],xtitle='Radius [degrees]',ytitle='R,G or B profile',xstyle=3,ystyle=3,/nodata,radius,spun
if (icol eq 1) then oplot,radius,spun,color=fsc_color('red')
if (icol eq 2) then oplot,radius,spun,color=fsc_color('green')
if (icol eq 3) then oplot,radius,spun,color=fsc_color('blue')
endfor
for  icol=1,3,1 do begin
subim=reform(im(*,*,icol-1))
if (icol eq 1) then subim=subim-40.
if (icol eq 2) then subim=subim-25.
if (icol eq 3) then subim=subim-20.
subim=subim(1489-w:1489+w,258-w:258+w)
spinit,subim,radius,spun
if (icol eq 1) then plot_oo,title='Moon halo from stock DSLR image',xrange=[0.1,10],yrange=[1,300],xtitle='Radius [degrees]',ytitle='R,G or B profile',xstyle=3,ystyle=3,/nodata,radius,spun
if (icol eq 1) then oplot,radius,spun,color=fsc_color('red')
if (icol eq 2) then oplot,radius,spun,color=fsc_color('green')
if (icol eq 3) then oplot,radius,spun,color=fsc_color('blue')
endfor
x=findgen(100)+1
x=x/10
p1=100./x^2.9 
oplot,x,p1*0.44
p2=20./x^1.3
oplot,x,p2*0.8
xyouts,/normal,0.6,0.4,'Slope=-2.9'
xyouts,/normal,0.3,0.3,'Slope=-1.3'
end
