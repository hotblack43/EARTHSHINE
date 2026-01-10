!P.MULTI=[0,3,4]
files=file_search('OUTPUT/ideal*')
im1=readfits(files(0),h1)
n=n_elements(files)
openw,33,'ratio_data.dat'
for i=1,n-1,1 do begin
	im2=readfits(files(i),h2)
	print,h2(9)
	rat=im1/im2
	idx=where(finite(rat) eq 1)
	print,moment(rat(idx))
	plot,rat(*,270),charsize=1.4,xtitle='Column',ytitle='Pixel ratio, row 270',yrange=[0.99,1.01],ystyle=1
	number=mean(rat(150:250,270))/mean(rat(320:360,270))
	printf,33,format='(5(f10.4,1x))',moment(rat(idx)),number
endfor
close,33
file='ratio_data.dat'
data=get_data(file)
help,data
mean=reform(data(0,*))
var=reform(data(1,*))
number=reform(data(4,*))
!P.MULTI=[0,1,3]
plot,mean,ystyle=1,ytitle='Mean of image ratios ',charsize=1.3,xtitle='Seconds apart',title='Simulated Moon images'
plot,sqrt(var),ystyle=1,ytitle='Std. dev. of image ratios ',charsize=1.3,xtitle='Seconds apart',title='Simulated Moon images'
plot,number,ystyle=1,ytitle='DS vs BS in ratio image ',charsize=1.3,xtitle='Seconds apart',title='Simulated Moon images'
end
