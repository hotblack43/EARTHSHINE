common xsandYs,X,Y,xyflag
xyflag=1
names=file_search('/data/pth/DARKCURRENTREDUCED/DISKESTIAMTEDANDROTATED/EFMCLEANED/245*.fits',count=n)
for i=0,n-1,1 do begin
name=names(i)
print,name
im=readfits(name,/silent)
findafittedlinearsurface,im,thesurface
writefits,'im.fits',im
writefits,'fitted.fits',thesurface
writefits,'corrected.fits',im-thesurface
endfor
end
