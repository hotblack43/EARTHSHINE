!P.CHARSIZE=2
!P.CHARTHICK=2
!P.THICK=3
!P.MULTI=[0,1,1]
window,xsize=500,ysize=800
files=file_search('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455707/LAASER/*.fits*',count=n)
;files=file_search('/media/thejll/842cc5fa-1b81-4eba-b09e-6e6474647d56/MOONDROPBOX/JD2455707/LAASER/*.fits*',count=n)
for i=0,n-1,1 do begin
	print,i
	im=1.0d0*readfits(files(i))
	im=im-median(im)
	a=''
	angle=45.
	while (a ne 'q') do begin
		im2=rot(im,angle)
		contour,im2
		a=get_kbrd()
		if (a eq 'r') then angle=angle+0.65437
		if (a eq 'l') then angle=angle-0.56437
		print,i,' a,angle is ',a,angle
	endwhile
print,'Best angle ',angle,i
profile=mean(im2,dimension=1)
;profile=median(im2,dimension=1)
save,filename=strcompress('profile_'+string(i)+'.sav',/remove_all),profile
endfor
end

