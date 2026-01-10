; ge average image
path='C:\cygwin\home\Daddyo\GIFS\'
read_gif,path+'average.gif',avim
avim=double(avim)
sum=avim*0.0
files=file_search(path+'*.gif.*',count=n)
for i=0,n-1,1 do begin
read_gif,files(i),im
im=double(im)-double(avim)
sum=sum+im
tvscl,sum
print,i
endfor
end
