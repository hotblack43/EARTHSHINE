files=file_search('/media/thejll/842cc5fa-1b81-4eba-b09e-6e6474647d56/MOONDROPBOX/','*MOON*.fits*',count=n)
for i=0L,n-1,1 do begin
;print,files(i)
im=readfits(files(i),/silent)
l=size(im,/dimensions)
if (n_elements(l) gt 2) then im=avg(im,2)
if (l(0) eq 512 and l(1) eq 512) then begin
toprow=im(*,510)
botrow=im(*,2)
flag=0
if (max(im) gt 60000) then begin
	flag=1
	print,'Max toolarge!'
	tvscl,hist_equal(im)
	lastbad=files(i)
	print,files(i)
endif
if (max(toprow) gt 10*min(toprow)) then begin
	flag=2
	print,'UP drag!'
	tvscl,hist_equal(im)
	lastbad=files(i)
	print,files(i)
endif
if (max(botrow) gt 10*min(botrow)) then begin
	flag=3
	print,'DOWN drag!'
	tvscl,hist_equal(im)
	lastbad=files(i)
	print,files(i)
endif
endif
endfor
end
