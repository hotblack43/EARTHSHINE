files=file_search('/media/SAMSUNG/LAMPFLATSND/*DARK*',count=n)
ic=0
for i=0,n-1,1 do begin
im=readfits(files(i))
print,mean(im)
if (mean(im) gt 370 and mean(im) lt 410) then begin
if (ic eq 0) then sum=im
if (ic gt 0) then sum=sum+im
ic=ic+1
endif
endfor
writefits,'newbias.fits',sum/float(ic)
end
