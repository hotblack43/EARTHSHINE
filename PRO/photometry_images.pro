PRO get_inner_circle,im,x0,y0,inner_radius,star_and_sky
 common radius,r
 idx=where(r le inner_radius)
 print,n_elements(idx),' pixels inside inner circle.'
 print,'Inner Circle: min and max',min(im(idx)),max(im(idx))
 star_and_sky=total(im(idx))
 print,'total counts inside inner circle=',star_and_sky
 return
 end

 PRO get_sky,im,x0,y0,outer_radius,inner_radius,medianval
 common radius,r
 idx=where(r gt inner_radius and r le outer_radius)
 print,n_elements(idx),' pixels inside anulus.'
 print,'Annulus: min and max',min(im(idx)),max(im(idx))
 medianval=median(im(idx))
 print,'Annulus median = ',medianval
 return
 end

common radius,r
x0=476.0
y0=180.0
file='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455749/2455749.7563016TEST_MOON_VE2_AIR_NOTCENTER.fits'
file='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455749/2455749.7544531TEST_MOON_V_AIR_NOTCENTER.fits'
im=readfits(file)
l=size(im,/dimensions)
nx=l(0)
ny=l(1)
r=fltarr(nx,ny)
n=l(2)
for i=0,nx-1,1 do begin
for j=0,ny-1,1 do begin
r(i,j)=sqrt((i-x0)^2+(j-y0)^2)
endfor
endfor
inner_radius=5
outer_radius=15
openw,33,'Vcounts.dat'
;openw,33,'VE2counts.dat'
for i=0,n-1,1 do begin
get_inner_circle,reform(im(*,*,i)),x0,y0,inner_radius,star_and_sky
get_sky,reform(im(*,*,i)),x0,y0,outer_radius,inner_radius,medianval
star=star_and_sky-!pi*inner_radius^2*medianval
print,'Star=',star
printf,33,star,medianval
endfor
close,33
end
