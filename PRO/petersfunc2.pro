FUNCTION petersfunc2,a
;
;	An ellipse is fitted
;
common moon,image
common keep,bestcorr
x0=a(0)
y0=a(1)
r1=a(2)
r2=a(3)
corr=evaluate2(image,x0,y0,r1,r2)
if (corr lt bestcorr) then begin
print,format='(4(1x,f8.3),1x,f8.3)',a,corr
bestcorr=corr
endif
return,corr
end

