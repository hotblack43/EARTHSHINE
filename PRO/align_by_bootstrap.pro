PRO MCalign,nkill,im1,im2,offset
 nMC=100
 n=512L*512L
 mkill=n*nkill	; number of pixels to NOT 'kill' each time
 use1=im1
 for iMC=0,nMC-1,1 do begin
     idx=randomu(seed,mkill)*n
     use2=im2
     use2(idx)=median(im2)
     shifts=alignoffset(use1,use2)
     if (iMC eq 0) then offset=shifts
     if (iMC gt 0) then offset=[[offset],[shifts]]
     endfor
 print,'Mean shifts: ',mean(offset(0,*)),' +/- ',stddev(offset(0,*)),mean(offset(1,*)),' +/- ',stddev(offset(1,*))
 return
 end
 
 im1=double(readfits('observed.fits'))
 im1=im1/total(im1)
 im2=double(readfits('trialout117.fits'))
 im2=im2/total(im2)
 !P.MULTI=[0,1,2]
 MCalign,0.9,im1,im2,offset
 plot,offset(0,*),offset(1,*),psym=7,/isotropic,xstyle=3,ystyle=3
 MCalign,0.6,im1,im2,offset
 plot,offset(0,*),offset(1,*),psym=7,/isotropic,xstyle=3,ystyle=3
 end
