bias=readfits('./TTAURI/superbias.fits',/silent)
 
 type='DOME';'SKY';'LAMP'
 filters=['B','V','VE1','VE2','IRCUT']
 for ifilter=0,4,1 do begin
 filter=filters(ifilter)
 flats=[]
 names=filter+'_'+type+'FLATS.txt'
 print,'Reading from: ',names
 openr,1,names
 while not eof(1) do begin
     str=''
     readf,1,str
     im=readfits(str,h,/silent)
     l=size(im)
     if (l(0) eq 2) then begin
         im=im-bias
         if (max(im) gt 10000 and max(im) lt 53000) then flats=[[[flats]],[[im]]]
         endif
     if (l(0) eq 3) then begin
         for k=0,l(3)-1,1 do begin
             if (median(im(*,*,k)) gt 10000 and median(im(*,*,k)) lt 53000) then flats=[[[flats]],[[im(*,*,k)-bias]]]
             endfor
         endif
     endwhile
 close,1
 l=size(flats,/dimensions)
 nflats=l(2)
 print,'There are ',nflats,' flats.'
 for k=0,nflats-1,1 do begin
 flats(*,*,k)=flats(*,*,k)/median(flats(*,*,k))
 tvscl,hist_equal(flats(*,*,k))
 endfor
 flat=median(flats,dimension=3)
 tvscl,hist_equal(flat)
 print,'sigma prime :', mean(stddev(flats,dimension=3))
 print,'sigma       :', stddev(flats)
 print,'sigma hi-f 1:',stddev(flat-sfit(flat,1))
 print,'sigma hi-f 2:',stddev(flat-sfit(flat,2))
 print,'sigma hi-f 3:',stddev(flat-sfit(flat,3))
 print,'Max-Min of fitted 1st-order surface: ',max(sfit(flat,1))-min(sfit(flat,1))
 print,'Max-Min of fitted 2nd-order surface: ',max(sfit(flat,2))-min(sfit(flat,2))
 writefits,strcompress(filter+'_'+'super'+type+'flat.fits',/remove_all),flat
 endfor
 end
