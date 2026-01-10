



files=file_search('residuals_*.fits',count=n)
stack=[]
w=11
for i=0,n-1,1 do begin
sheet=readfits(files(i))
squareav=mean(sheet(50-w:50+w,202-w:202+w),/double)
print,i,squareav
sheet=sheet-squareav
stack=[[[stack]],[[sheet]]]
endfor
l=size(stack,/dimensions)
avim=avg(stack,2)
SDim=stddev(stack,dimension=3)/sqrt(l(2)-1)	; i.e. SD of mean
Zim=abs(SDim/avim*100.)
writefits,'avim.fits',avim
writefits,'SDim.fits',SDim
writefits,'Zim.fits',Zim
end
