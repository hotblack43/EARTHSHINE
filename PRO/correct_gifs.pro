; get the average frame
av=readfits('average.fit')
subim=av(140:190,140:190)
refval=mean(av)
p='C:\cygwin\home\Daddyo\GIFS\'
files=file_search(p+'aha.gif.*',count=n)
sum=dblarr(375,375)
for i=0,n-1,1 do begin
	read_gif,files(i),im
	subim=av(140:190,140:190)
	im=im-av/refval*mean(im)
	sum=sum+double(im)
	tvscl,sum
	print,i
endfor

end