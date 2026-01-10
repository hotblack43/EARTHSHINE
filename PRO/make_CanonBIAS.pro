files=file_search('E:\Image*.JPG',count=n)
for i=0,50,1 do begin
print,i,n
	read_jpeg,files(i),im
	im=reform(im(0,*,*))
	if (i eq 0) then stack=im
	if (i gt 0) then stack=[[[stack]],[[im]]]
	help,stack
endfor
bias1=median(stack,dimension=3)
writefits,'E:\BIAS1.fit',bias1
stack=0
for i=51,95,1 do begin
print,i,n
	read_jpeg,files(i),im
	im=reform(im(0,*,*))
	if (i eq 51) then stack2=im
	if (i gt 51) then stack2=[[[stack2]],[[im]]]
	help,stack2
endfor
bias2=median(stack2,dimension=3)
bias2=0
writefits,'E:\BIAS2.fit',bias2
end
