 PRO aligncollapsedcolumns,im,ref
 ; Code to align a stack of images by collapsing each image 
; to a along-columns-sum and aligning the resulting rows.
; INPUT: im (a stack of images)
; OUTPUT: ref - the best-aligned along-columns sum for aligned such rows
 l=size(im)
 if (l(0) ne 3) then begin
     print,'This is not a stack. Stopping'
     stop
     endif
 nims=l(3)
 ; create rows from images in stack
 rows=dblarr(512,nims)
 for i=0,nims-1,1 do begin
     rows(*,i)=avg(im(*,*,i),1,/double)
     endfor
 ; align the rows
 nshifts=9
 deltas=findgen(nshifts)-2
 c=fltarr(nshifts)
 ic=1
 itc=0
 while (ic ne 0) do begin
;print,'iterated alignment ...'
 ic=0
 ref=avg(rows,1,/double)
 for k=0,nims-1,1 do begin
     for l=0,nshifts-1,1 do c(l)=correlate(ref,shift(reform(rows(*,k)),deltas(l)),/double)
     bestshift=deltas(where(c eq max(c)))
     if (bestshift(0) ne 0) then begin
         rows(*,k)=shift(reform(rows(*,k)),bestshift(0))
;        print,'Did shift row ',k,' by ',bestshift(0)
         ic=ic+1
         endif
     endfor
 itc=itc+1
 endwhile
 print,'Iterated ',itc-1,' times.'
 return
 end
 
 
 
 
 
 
 
 
 
 
 
 
 files=file_search('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456045/*MOON_*.fits.gz',count=nims)
 for iims=0,nims-1,1 do begin
 file=files(iims)
 im=double(readfits(file,h))
 !P.MULTI=[0,1,2]
 orig=avg(avg(im,2,/double),1,/double)
 plot,xstyle=3,xtitle='Column #',ytitle='Intensity',title='Effect of aligning collapsed images',orig-394,/ylog,yrange=[0.9,10],ystyle=3
 aligncollapsedcolumns,im,aligned
 oplot,aligned-394,color=fsc_color('red')
 plot,xstyle=3,xtitle='Column #',ytitle='% change',(orig-aligned)/orig*100.,yrange=[-0.01,0.01]
 oplot,[!X.crange],[0,0],color=fsc_color('red')
 endfor
 end
