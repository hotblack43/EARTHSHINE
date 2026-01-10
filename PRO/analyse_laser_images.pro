files=file_search('/media/thejll/OLDHD/MOONDROPBOX/JD2455707/LAASER/2455707.7*',count=n)
bias=readfits('TTAURI/superbias.fits')
stack=[]
for i=0,n-1,1 do begin
im=readfits(files(i))-bias
stack=[[[stack]],[[im]]]
endfor
tvscl,avg(stack,2)
end
