; Aligns on most recent sum image, then updates reference, iterates
;
path='FAKEOBSERVED/'
 files=file_search(path+'fake_observe*.fits',count=n)
 im0=double(readfits(files(0),/NOSCALE,/SILENT))
 saved_im=im0
 niter=20
 openw,91,'deltasum_v2.dat'
 for iter=1,niter,1 do begin
     sum=im0
     deltasum=0.0
     openw,44,'shift_stats_v2.dat'
     for iim=1,n-1,1 do begin
         im=double(readfits(files(iim),/NOSCALE,/SILENT))
         shifts=alignoffset(im,im0,Cor)
         im=shift_sub(im,-shifts(0),-shifts(1))
         sum=sum+im
         delta=sqrt(shifts(0)^2+shifts(1)^2)
         deltasum=deltasum+delta
         printf,44,iim,shifts(0),shifts(1),total(im,/double)
         im0=sum
     endfor
     sum=sum/float(n)
     im0=sum
     writefits,strcompress('Fake_coadded_iteration_'+string(n+1)+'.fits',/remove_all),sum

     close,44
     print,'Deltasum=',deltasum
     print,'Total sq difference of ims:',total((saved_im-im0)^2,/double)
     printf,91,iter,deltasum,max(sum),total((saved_im-im0)^2,/double)
     saved_im=im0
 endfor	; end of iter loop
 close,91
 end

