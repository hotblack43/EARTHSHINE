; get the average frame
p='C:\cygwin\home\Daddyo\GIFS\'
files=file_search(p+'aha.gif.*',count=n)
sum=dblarr(375,375)
for i=0,n-1,1 do begin
	read_gif,files(i),im
	sum=sum+double(im)
	tvscl,sum
	print,i
endfor
writefits,'average.fit',sum/float(n)
end