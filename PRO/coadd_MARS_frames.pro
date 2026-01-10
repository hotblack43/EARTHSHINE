; Coadds frames from disk (i.e. does not use up memory on making stacks),
 avim=readfits('coadded_frame.fits')
 bias=readfits('superbias.fits')
 files=file_search('/media/thejll/OLDHD/MOONDROPBOX/JD2455940/2455940.*MARS_V*',count=n)
 print,'Found ',n,' frames'
 list=[]
 sum=dblarr(512,512)
 for k=0,n-1,1 do begin
     im=readfits(files(k),/sil)
     l=size(im)
     print,l
     if (l(0) eq 3 and max(im) gt 2000 and max(im) lt 55000) then begin
         print,max(im)
         for i=0,l(3)-1,1 do begin
             offsets=alignoffset(avim,im(*,*,i))
             print,format='(2(1x,f9.4))',offsets
             sum=sum+shift_sub(reform(im(*,*,i))-bias,offsets(0),offsets(1))
             endfor
         avim=sum
         tvscl,hist_equal(avim)
         endif
     endfor
 writefits,'coadded_frame.fits',avim
 end
