PRO gogetthebest,im,ic
 ; will check all slices in the stack and keep only the good ones
 ic=0
 isthereasinglegoodframe=0
 l=size(im,/dimensions)
 for i=0,l(2)-1,1 do begin
     slice=reform(im(*,*,i))
     if (max(slice) gt 0 and max(slice) lt 53000) then begin
     ;if (max(slice) gt 10000 and max(slice) lt 53000) then begin
         isthereasinglegoodframe=1
         if (ic eq 0) then stack=slice
         if (ic gt 0) then stack=[[[stack]],[[slice]]]
         ic=ic+1
         endif
     endfor
 if (isthereasinglegoodframe ne 0) then im=stack
 if (isthereasinglegoodframe eq 0) then im=im*0.0-999
 return
 end
 
 PRO goalignthatgoodstack_iteratively,im_in,h,ifcubic
 im=im_in
 ; will align all images in im and return a stack of aligned images
 ; firstget an average image to align against
 reference=avg(im,2,/double)
 ; loop over all images ins tack and align with reference
 l=size(im,/dimensions)
 n=l(2)
 newstack=im*0.0
 niter=4
 combined_offset=fltarr(2,n)
 for iter=0,niter-1,1 do begin
     sum=0.0
     for i=0,n-1,1 do begin
         offset = alignoffset(im(*,*,i), reference, corr)
         offset=[offset(0),offset(1),0.0]
         if (iter eq 0) then combined_offset(0,i)=offset(0)
         if (iter eq 0) then combined_offset(1,i)=offset(1)
         if (iter gt 0) then combined_offset(0,i)=combined_offset(0,i)+offset(0)
         if (iter gt 0) then combined_offset(1,i)=combined_offset(1,i)+offset(1)
         if (ifcubic eq 1) then shifted_im=shift_sub_cubic(im(*,*,i),-offset(0),-offset(1))
         if (ifcubic ne 1) then shifted_im=shift_sub(im(*,*,i),-offset(0),-offset(1))
         sum=sum+sqrt(offset(0)^2+offset(1)^2)
         newstack(*,*,i)=shifted_im
         endfor
     print,'RMS offsets in iteration: ',iter,sum
     im=newstack
     endfor
 ; Now use the accumulated shifts to shift the original image, once
 for i=0,n-1,1 do begin
     if (ifcubic eq 1) then im_in(*,*,i)=shift_sub_cubic(im_in(*,*,i),-combined_offset(0,i),-combined_offset(1,i))
     if (ifcubic ne 1) then im_in(*,*,i)=      shift_sub(im_in(*,*,i),-combined_offset(0,i),-combined_offset(1,i))
     endfor
 sxaddpar, h, 'ALIGNED', niter, 'iterated alignment that many times'
 return
 end
 
 PRO coaddslicesIntelligently,im,h,VOM,ifcubic
 ; will average a stack of images, if a stack is present
 l=size(im)
 if (l(0) lt 3) then begin
     sxaddpar, h, 'COADDING', 0, 'No stack present, no averaging'
     return
     endif else begin
     gogetthebest,im,ngood
     l=size(im,/dimensions)
     if (ngood ge 2) then begin
         goalignthatgoodstack_iteratively,im,h,ifcubic
         ; now build the VOM
         produce_VOM,im,SD,MN,VOM
         im=avg(im,2,/double)
         sxaddpar, h, 'COADDING', l(2), 'frames in stack averaged'
         endif else begin
         sxaddpar, h, 'COADDING', ngood, ' not even 2 good frames in stack!'
         endelse
     return
     endelse
 end
 
 PRO produce_VOM,original_in,SD,MN,VOM
 common stuff,RON,ADU,biasfactor
 original=original_in
 bias=readfits('superbias.fits'); ADU
 bias=bias*0.0+100.0
 print,'RON is: ',RON
 print,'biasfactor is: ',biasfactor
 l=size(original,/dimensions)
 ; subtract vias (in ADU) and convert to electrons
 for k=0,l(2)-1,1 do original(*,*,k)=(original(*,*,k)-bias(*,*)*biasfactor)*ADU    ; convert counts to electrons
 SD=fltarr(512,512)
 MN=fltarr(512,512)
 VOM=fltarr(512,512)
 ; calculate SD, mean and variance-over-mean images
 for i=0,511,1 do begin
     for j=0,511,1 do begin
 ;        print,i,' ',j,' ',mean(original(i,j,*)),stddev(original(i,j,*))
         SD(i,j)=stddev(original(i,j,*))-RON
         ; the RON is subtracted in units of electrons
         MN(i,j)=mean(original(i,j,*),/double)
         VOM(i,j)=SD(i,j)^2/MN(i,j)
         endfor
     endfor
 return
 end

 common stuff,RON,ADU,biasfactor
 ADU=1.0;3.8 ; electrons/ADU according to ANDOR manual
 biasfactor=1.00
 RON=2.1408*ADU; 8.3 ; electrons. ANDOR and our analysis
 !P.MULTI=[0,1,3]
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
 ;for biasfactor=0.98,1.02,0.005 do begin
 ;for RON=8.04,8.24,0.025 do begin
 lowpath='/data/pth/DATA/ANDOR'
 ;original=double(readfits('ideal_stack_jiggled.fit'))
 original=double(readfits('ideal_stack_notjiggled.fit'))
 print,'mean at 133,285 is: ',mean(original(133,285,*)), ' SD^2 is : ',stddev(original(133,285,*))^2
stop
 print,'mean original: ',mean(original,/double),stddev(original)
 print,min(Original),max(original)
 ;original=double(readfits(lowpath+'/MOONDROPBOX/JD2456004/2456004.1639861MOON_V_AIR.fits.gz'))
 produce_VOM,original,SD,MN,VOM
 print,'mean original: ',mean(original,/double),stddev(original)
 print,'mean VOM: ',mean(vom,/double),stddev(vom)
 writefits,'VOM.fits',VOM
 writefits,'SD.fits',SD
 writefits,'MN.fits',MN
 plot,/ylog,original(*,256),xstyle=3,ystyle=3,title='RON: '+string(RON,format='(f6.4)')+' at bias.f.: '+string(biasfactor,format='(f6.4)')
 plots,[55,55],[!Y.crange],linestyle=2
 plot,ytitle='VOM',xtitle='Column #',title='Before alignment',xstyle=3,ystyle=3,vom(*,256),/ylog,yrange=[0.0001,10000.]
 plots,[!x.crange],[1,1],linestyle=0
 ;plots,[!x.crange],[.1,.1],linestyle=1
 ;
 ifcubic=0
 coaddslicesIntelligently,original,h,VOM2,ifcubic
 print,'mean aligned : ',mean(vom,/double),stddev(vom)
 writefits,'VOM2.fits',VOM2
 plot,ytitle='VOM',xtitle='Column #',title='After alignment',xstyle=3,ystyle=3,vom2(*,256),/ylog,yrange=[0.0001,10000.]
 plots,[!x.crange],[1,1],linestyle=0
 ;plots,[!x.crange],[.1,.1],linestyle=1
 ;endfor	; end of RON loop
 ;endfor ; end of biasfactor loop
 end
