; Align images from M20
 stack=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456106/M22_M20/2456107.0964071M20_VE2_AIR.fits')
 stack=stack(*,*,3:11)             
 l=size(stack,/dimensions)
 nims=l(2)
 im1=stack(*,*,0)     
 aligned=im1
 for imnum=1,nims-1,1 do begin
     im2=stack(*,*,imnum)
     offset = alignoffset(im1,im2,corr)
     print,offset
     im2=shift_sub(im2,+offset(0),+offset(1))
     aligned=[[[aligned]],[[im2]]]
     diff=im1-im2
     tvscl,hist_equal(diff)
     endfor
 writefits,'aligned_M20.fits',avg(aligned,2)
 print,'=================================='
 aligned=readfits('aligned_M20.fits')
 offsets=[]
 for imnum=0,nims-1,1 do begin
     im2=stack(*,*,imnum)     
     offset = alignoffset(aligned,im2,corr)
     offsets=[[offsets],[offset]]
     print,offset
     im2=shift_sub(im2,+offset(0),+offset(1))
     diff=aligned-im2
     tvscl,hist_equal(diff)
     endfor
 ; super-align just one frame brute force
 hanni=hanning(512,512)
 stack_bestdiff=[]
 for imuse=0,nims-1,1 do begin
     diff_min=1e22
     print,'im ',imuse
     x0=offsets(0,imuse)
     y0=offsets(1,imuse)
     for dx=x0*0.91,x0*1.10,x0/100. do begin
         for dy=y0*0.91,y0*1.10,y0/100. do begin
             diff=hanni*aligned-hanni*shift_sub(stack(*,*,imuse),dx,dy)
             tot=total(diff^2)
             str=''
             if (tot le diff_min) then begin
                 diff_min=tot
                 str='*'
                 dx_best=dx
                 dy_best=dy
                 diff_best=aligned-shift_sub(stack(*,*,imuse),dx,dy)
                 endif
             ;print,dx,dy,tot,str
             tvscl,hist_equal(diff)
             endfor
         endfor
     print,'Best shift: ',dx_best,dy_best,diff_min,' for image ',imuse
     tvscl,hist_equal(diff_best)
     stack_bestdiff=[[[stack_bestdiff]],[[diff_best]]]
     endfor
     writefits,'stack_bestdiff.fits',stack_bestdiff
 end
