; set up a svcaled-down white disk as the Moon, inside a FITS file
n=512
im=dblarr(n,n)*0.0d0+1.0d0
platescale=7.4 ; arsec/pixel
scaledownfactor=1./3
r=1800./2./platescale*scaledownfactor
print,r
x0=n/2
y0=n/2
for i=0L,n-1,1 do begin
	for j=0L,n-1,1 do begin
	im(i,j)=sqrt((i-x0)^2+(j-y0)^2)
	endfor
	print,i
endfor
writefits,'smalldisc.fits',im le 45
print,'Done'
end
