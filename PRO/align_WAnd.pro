; Aligns on first image, then updates reference, iterates
; get the bias frame
bias=readfits('../BIASFRAMES/bias_half_median_sfit_order_2.fits')
 ;
 path='/media/SAMSUNG/MOONDROPBOX/MOONDROPBOX/JD2455461/DoubleStar-WAnd/'
 files=file_search(path+'00000_2455461_*',count=n)
 ; first make a straight mean (no alignmnets) of the whole 
 ; set of images - for the reference im
 for iim=0,n-1,1 do begin
     im=double(readfits(files(iim),/NOSCALE,/SILENT))-bias
     if (iim eq 0) then sum=im
     if (iim gt 0) then sum=sum+im
     endfor
 im0=sum/float(n)
 compare_im=im0
 niter=10
 openw,91,'deltasum.dat'
 sum=im0
 for iter=0,niter,1 do begin
     deltasum=0.0
     openw,44,'shift_stats.dat'
     for iim=1,n-1,1 do begin
         im=double(readfits(files(iim),/NOSCALE,/SILENT))-bias
         shifts=alignoffset(im,im0,Cor)
         im=shift_sub(im,-shifts(0),-shifts(1))
         sum=sum+im
         delta=sqrt(shifts(0)^2+shifts(1)^2)
         deltasum=deltasum+delta
         printf,44,iim,shifts(0),shifts(1),total(im,/double)
         endfor
     sum=sum/float(n)
     im0=sum
     close,44
     print,'Deltasum=',deltasum
     print,'Total sq difference of ims:',total((compare_im-im0)^2,/double)
     printf,91,iter,deltasum,max(sum),total((compare_im-im0)^2,/double)
     compare_im=im0
     endfor	; end of iter
 writefits,strcompress('WAnd_coadded_iteration_'+string(n+1)+'.fits',/remove_all),sum
 close,91
 end
 
