 
 
 PRO aligncollapsedcolumns,im,ref,nims
 l=size(im)
 print,l
 nims=1
 if (l(0) ne 3) then begin
     print,'This is not a stack. Returning without alignment'
     help,im
     ref=avg(im,1,/double)
     return
     endif
 nims=l(3)
 ; check the satck, get rid of duds
 ic=0
 for i=0,nims-1,1 do begin
 if (max(im(*,*,i)) gt 10000 and max(im(*,*,i)) lt 53000) then begin
 if (ic eq 0) then newim=im(*,*,i)
 if (ic gt 0) then newim=[[[newim]],[[im(*,*,i)]]]
 ic=ic+1
 endif
 endfor
 if (ic ne 0) then begin
	im=newim
 l=size(im)
 print,l
 nims=1
 if (l(0) ne 3) then begin
     print,'This is not a stack. Returning without alignment'
     help,im
     ref=avg(im,1,/double)
     return
     endif
 nims=l(3)
	endif
 if (nims lt 4) then return
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
 
 
 
 PRO getthename,file,name
; /data/pth/DATA/ANDOR/MOONDROPBOX/JD2455748/2455748.7576445TEST_MOON_IR
bits=strsplit(file,'/',/extract)
print,bits
idx=strpos(bits,'245')
jdx=where(idx eq 0)
if (jdx(0) eq -1) then begin
	print,'String starting 245... never found'
	stop
endif
name=bits(jdx(0))
;print,'1: ',name
bits=strsplit(name,'.fits',/extract)
name=strmid(name,0,strpos(name,'.fit'))
;print,'2: ',name
return
end
 
 
 
 
 
 
 
 
 
 files=file_search('/data/pth/DATA/ANDOR/MOONDROPBOX/','24*MOON_*.fits*',count=nims)
 for iims=0,nims-1,1 do begin
 file=files(iims)
print,file
 getthename,file,name
 im=double(readfits(file,h))
 l=size(im)
 !P.MULTI=[0,1,2]
 if (l(0) eq 3) then orig=avg(avg(im,2,/double),1,/double)
 if (l(0) ne 3) then orig=avg(im,1,/double)
 plot,xstyle=3,xtitle='Column #',ytitle='Intensity',title='Effect of aligning collapsed images',orig-394,/ylog,yrange=[0.9,10],ystyle=3
 aligncollapsedcolumns,im,aligned,nims
 oplot,aligned-394,color=fsc_color('red')
 plot,xstyle=3,xtitle='Column #',ytitle='% change',(orig-aligned)/orig*100.,yrange=[-0.01,0.01]
 oplot,[!X.crange],[0,0],color=fsc_color('red')
 ; save aligned rows
 filename=strcompress('/data/pth/ANDOR/COLLAPSED/collapsed_'+name+'.fits')
 sxaddpar, h, 'COMMENT', 0, 'This image column-summed to one row'
 sxaddpar, h, 'NIMS', nims, 'This many images in the stack'
 writefits,filename,aligned,h
 endfor
 end
