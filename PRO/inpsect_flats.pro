files=file_search('*FLAT*.fits',count=n)
openw,44,'bestorder.dat'
for i=0,n-1,1 do begin
im=readfits(files(i))
titstr=files(i)
verysmall=1e33
bestorder=911
maxorder=5
for j=1,maxorder,1 do begin
y=sfit(im,j)
residuals=im-y
sd=stddev(residuals)
print,sd,j
if (sd lt verysmall) then begin
	bestorder=j
	verysmall=sd
endif
endfor
if (bestorder eq maxorder) then stop
printf,44,format='(i2,1x,f9.3,1x,a)',bestorder,verysmall,titstr
print,format='(i2,1x,f9.3,1x,a)',bestorder,verysmall,titstr
endfor
close,44
end
