!P.MULTI=[0,1,2]
common peterspecial,phi,inc

files=file_search('/home/pth/SCIENCEPROJECTS/EARTHSHINE/OUTPUT/IDEAL/ideal*.fit')
n=n_elements(files)
	openw,4,'p.dat'
for i=0,n-1,1 do begin
	im=double(readfits(files(i),header))
	jd=header(8)
	jd=double(strmid(jd,11,19))
	ratio=im(340,493)/im(678,565)
	mphase,jd,k
	print,format='(f20.6,1x,f15.10,4(1x,f8.4))',jd,ratio,k,phi,inc
	printf,4,jd,ratio,k,inc
endfor
close,4
data=get_data('p.dat')
jd=reform(data(0,*))
ratio=reform(data(1,*))
phase=reform(data(2,*))
plot_io,jd-jd(0),ratio,charsize=2,xtitle='Day',ytitle='I!dSun!n/I!dEarth!n',yrange=[1e3,3e5],ystyle=1
plots,[2,2],[1e-5,1e5],linestyle=2
plots,[8,8],[1e-5,1e5],linestyle=2
plots,[18,18],[1e-5,1e5],linestyle=2
plots,[25,25],[1e-5,1e5],linestyle=2
plot,jd-jd(0),phase,charsize=2,xtitle='Day',ytitle='Illuminated fraction'
;plot_io,phase,ratio,psym=3,xtitle='Illuminated fraction',ytitle='I!dSun!n/I!dEarth!n',charsize=2
end
