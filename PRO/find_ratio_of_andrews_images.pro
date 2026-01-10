FUNCTION moon_field_rotation,jd,station_long,station_lati
	MOONPOS, jd, ra, dec, dis, geolong, geolat
	eq2hor, ra, dec, jd, moon_alt, moon_az,lon=station_long,lat=station_lati
	rotation_rate=4.1666e-3*cos(station_lati*!dtor)*cos(moon_az*!dtor)/cos(moon_alt*!dtor)
	return,rotation_rate
	end
files=file_search('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\AUSTRALIAMOON\moon*.FIT',count=N)
darkframe=double(readfits('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\AUSTRALIAMOON\sydneydark.fit'))
im1orig=double(readfits(files(0),header1))
im1=im1orig-darkframe
moon_field_rotation,jd,station_long,station_lati
N=50

l=size(im1,/dimensions)
factor=2
x=indgen(l(0)*factor)

for i=1,N-1,1 do begin
im1=rebin(im1,l(0)*3,l(1)*3)
im2orig=double(readfits(files(i)))
im2=im2orig-darkframe
im2=rebin(im2,l(0)*factor,l(1)*factor)
get_FFT_shift,im1,im2,shiftx,shifty

im3=shift(im2,-shiftx,-shifty)
im1=rebin(im1,l(0),l(1))
im3=rebin(im3,l(0),l(1))
idx=where(im3 ne 0)
ratio=im1*0.0+1.0
ratio(idx)=im1(idx)/im3(idx)
!P.MULTI=[0,1,2]
plot,ratio(135/factor:570/factor,516/factor),min=0.,max=2.1,ystyle=1,xstyle=1,xtitle='CCD column',ytitle='pixel ratio',charsize=2
tvscl,im1orig/im2orig
endfor
end