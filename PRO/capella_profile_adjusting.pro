im=readfits('capella_coadded.fits')
;
x0=31.1
y0=34.9
key='q'
print,'Press u,d,l or r key - q to quit'
start:
	key=get_kbrd()
	print,key
	dx=0.0
	dy=0.0
        da=0.0
        da=0.0
	if (key eq 'u') then begin
	dy=0.1
	endif	
	if (key eq 'd') then begin
	dy=-0.1
	endif	
	if (key eq 'r') then begin
	dx=0.1
	endif	
	if (key eq 'l') then begin
	dx=-0.1
	endif	
	x0=x0+dx
	y0=y0+dy

openw,44,'capella_profile.dat'
for i=0,63,1 do begin
for j=0,63,1 do begin
r=sqrt((i-x0)^2+(j-y0)^2)
printf,44,r,im(i,j)
endfor
endfor
close,44
data=get_data('capella_profile.dat')
r=reform(data(0,*))
f=reform(data(1,*))
plot_oo,r,f-0.9,xrange=[0.1,100],psym=3,yrange=[1e-2,1e4]
if (key ne 'q') then goto, start
end

