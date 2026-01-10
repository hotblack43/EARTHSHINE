spawn,'rm img*.png'
n=40
for i=0,n-1,1 do begin
name=strcompress('img'+string(i)+'.png',/remove_all)
str=strcompress('vgrabbj > '+name)
print,str
spawn,str
endfor
files=file_search('.','img*.png')
n=n_elements(files)
for i=0,n-1,1 do begin
	im=read_png(files(i))
	im=total(im,1)/3.
	print,moment(im)
	if (i eq 0) then stack=im
	if (i ne 0) then stack=[[[stack]],[[im]]]
	surface,im
endfor
	final=total(stack,3)/float(n)
	surface,final
	print,moment(final)
end
