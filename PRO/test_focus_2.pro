PRO make_radius,im,radius
l=size(im,/dimensions)
radius=fltarr(l(0),l(1))
for i=0,l(0)/2.-1,1 do begin
for j=0,l(1)/2.-1,1 do begin
radius(i,j)=sqrt(i^2 +j^2)
endfor
endfor
return
end

files=file_search('/data/pth/DATA/ANDOR/OUTDATA/JD2455482/Capella_darkreduced_*.fits',count=n)
openw,11,'focus.dat'

for i=0,n-1,1 do begin
im=readfits(files(i))
if (i eq 0) then begin
make_radius,im,radius
endif
z=ffT(im,-1,/double)
zz=float(z*conj(z))
yfit = GAUSS2DFIT(im, B)
fwhm=sqrt(b(2)^2+b(3)^2)
idx=where(radius gt 2 and radius lt 5)
jdx=where(radius gt 15 and radius lt 30)
focus=total(zz(jdx))/total(zz(idx))
print,i,focus,fwhm
printf,11,i,focus,fwhm
endfor
close,11
data=get_data('focus.dat')
focus=reform(data(1,*))
fwhm=reform(data(2,*))
plot,focus,fwhm,psym=3,xtitle='Focus from spectral slope',ytitle='FWHM fitted Gaussian',charsize=2,xstyle=1,ystyle=1
print,'R :',correlate(focus,fwhm)
end
