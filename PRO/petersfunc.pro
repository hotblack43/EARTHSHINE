FUNCTION petersfunc,a
common moon,image
common keep,bestcorr
x0=a(0)
y0=a(1)
r=a(2)
corr=evaluate(image,x0,y0,r)
if (corr lt bestcorr) then begin
print,format='(3(1x,f8.3),1x,f8.3)',a,corr
bestcorr=corr
endif
return,corr
end

