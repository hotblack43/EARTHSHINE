starname='ALTAIR'
path='/home/pth/SCIENCEPROJECTS/EARTHSHINE/DARKCURRENTREDUCED/'
names=['B','V','VE1','VE2','IRCUT']
for iname=0,4,1 do begin
filtername=names(iname)
files=file_search(strcompress(path+'*'+filtername+'*'+'.fits',/remove_all),count=n)
imref=readfits(files(n/2))
sum=imref
imreftot=total(imref,/double)
for i=0,n-1,1 do begin
if (i ne n/2) then begin
im=readfits(files(i))
;perform_annulus_photom,mag
;if (min(im) lt 0) then stop
         shifts=alignoffset(im,imref,Cor)
         shifted_im=shift_sub(im,-shifts(0),-shifts(1))
sum=sum+shifted_im/total(im,/double)*imreftot
surface,rebin(sum,64,64),/zlog,title=filtername,charsize=2
endif
endfor
sum=sum/float(n)
writefits,strcompress(starname+'_COMBINED_'+filtername+'.fits',/remove_all),sum
endfor
end
