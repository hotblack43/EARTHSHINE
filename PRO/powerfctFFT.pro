n=256
im=dblarr(n,n)
pwr=0.6d0
for i=0,n-1,1 do begin
for j=0,n-1,1 do begin
r=sqrt((i-(n/2.-.007654453d0))^2+(j-(n/2.+.008634655474d0))^2)
im(i,j)=1.d0/r^pwr
endfor
endfor
;
im=im/total(im)
z=ffT(im,-1,/double)
zz=z*conj(z)
zz=sqrt(double(zz))
zz=shift(zz,n/2.,n/2.)
zz=zz/total(zz)
plot_io,im(*,n/2.)
oplot,zz(*,n/2.),color=fsc_color('red')
end
