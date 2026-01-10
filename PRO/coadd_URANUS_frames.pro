files=file_search('/media/thejll/OLDHD/MOONDROPBOX/JD2455923/2455923.*URANUS_IRCUT_*',count=n)
 print,'Found ',n,' frames'
 stack=[]
 for i=0,n-1,1 do begin
     im=readfits(files(i))
     print,i,max(im)
     if (max(im) gt 10000) then begin
         stack=[[[stack]],[[im]]]
         endif
     endfor
 l=size(stack,/dimensions)
 print,l(2)
 avim=avg(stack,2)
 avim=readfits('coadded_frame.fits')
 niter=10
 newstack=[]
     old_offsets=fltarr(2,l(2))
 for iter=0,niter-1,1 do begin
     print,'iter: ',iter
     for i=0,l(2)-1,1 do begin
         offsets=alignoffset(avim,stack(*,*,i))
         print,format='(2(1x,f9.4))',offsets-old_offsets(*,i)
         old_offsets(0,i)=offsets(0)
         old_offsets(1,i)=offsets(1)
         newstack=[[[newstack]],[[shift_sub(stack(*,*,i),offsets(0),offsets(1))]]]
         endfor
     avim=avg(newstack,2)
     tvscl,hist_equal(avim)
     endfor
 writefits,'coadded_frame.fits',avim
 end
