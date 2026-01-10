PRO manual_align,im,reference,offset,diff
	k=0
  	l=size(im,/dimensions)
	Nx=l(0)*1.0
	Ny=l(1)*1.0
  	offset = alignoffset(im, reference, corr)
        offset=[offset(0),offset(1),0.0]
; First get rough offset from 'alignoffset'
        shifted_im=shift_sub(im,-offset(0),-offset(1))
  window,3,xsize=512,ysize=512
  tvscl,congrid(shifted_im-reference,512,512)
key='q'
print,'Press R,L,u,d,l or r key - q to quit'
start:
	key=get_kbrd()
	print,key
	dx=0.0
	dy=0.0
        da=0.0
        da=0.0
	if (key eq 'u') then begin
	dy=0.46543875
	endif	
	if (key eq 'd') then begin
	dy=-0.54323
	endif	
	if (key eq 'r') then begin
	dx=0.58765
	endif	
	if (key eq 'l') then begin
	dx=-0.498654
	endif	
	if (key eq 'R') then begin
	da=0.1
	endif	
	if (key eq 'L') then begin
	da=-0.1
	endif	
	offset(0)=offset(0)+dx
	offset(1)=offset(1)+dy
	offset(2)=offset(2)+da
  shifted_im=shift_sub(im,-offset(0),-offset(1))
  shifted_im=ROT(shifted_im,offset(2))
  window,3,xsize=512,ysize=512
  diff=(float(shifted_im)-float(reference))/float(reference)
  diff=float(shifted_im)-float(reference)
  tvscl,diff
if (key ne 'q') then goto, start
im=shifted_im
return
end

 PRO go_normalize_with_mask,im,ifil,mask
; will normalize the masked image
 common reference,reftotal
	idx=where(mask eq 1)
 if (ifil eq 0) then begin
	reftotal=total(im(idx),/double)
	return
 endif
 im=im/total(im(idx),/double)*reftotal
 return
 end
	
 PRO get_images_single_b,n,bias
 files=file_search('PREPAREDFORDITHERING/*.fits',count=n)
; NOTE: since the images in PREPAREDFORDITHERING/ have been scaled to ensure same flux
; no additional scaling of flux is applied here
 reference=readfits(files(50))	; ref image to determine spatial shifts from
   if (n ge 999) then stop
     ;..................................
     openw,33,'detected_shifts.dat'
     for i=0,n-1,1 do begin
     im=readfits(files(i),header)
     manual_align,im,reference,offset,diff
     if (i le 9) then mnumname='000'+string(i)
     if (i gt 9 and i le 99) then mnumname='00'+string(i)
     if (i gt 99 and i le 999) then mnumname='0'+string(i)
     fname=strcompress('DATA/imagetouse'+mnumname+'.fit',/remove_all)
     writefits,fname,im
     printf,33,format='(2(1x,f9.1),1x,a)',offset(0),offset(1),fname
     endfor
     close,33
     return
     end
 
	
 PRO get_images_single,n,bias
 files=file_search('PREPAREDFORDITHERING/*.fits',count=n)
; NOTE: since the images in PREPAREDFORDITHERING/ have been scaled to ensure same flux
; no additional scaling of flux is applied here
 reference=readfits(files(20))	; ref image to determine spatial shifts from
   if (n ge 999) then stop
     if_bin=0 & nbin=512/1
     ;..................................
     openw,33,'detected_shifts.dat'
     if (if_bin eq 1) then reference=rebin(reference,nbin,nbin)
     for i=0,n-1,1 do begin
     im=readfits(files(i),header)
     if (if_bin eq 1) then im=rebin(im,nbin,nbin)
     out=im
     if (i le 9) then mnumname='000'+string(i)
     if (i gt 9 and i le 99) then mnumname='00'+string(i)
     if (i gt 99 and i le 999) then mnumname='0'+string(i)
     fname=strcompress('DATA/imagetouse'+mnumname+'.fit',/remove_all)
     offset = alignoffset(out, reference, corr)
     tvscl,[reference,shift(out,-offset(0),-offset(1))]
     writefits,fname,out
     printf,33,format='(2(1x,f9.1),1x,a)',offset(0),offset(1),fname
     endfor
     close,33
     return
     end

     PRO get_images_in_stack,n
     spawn,'rm DATA/*'
     file='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455749/2455749.7544531TEST_MOON_V_AIR_NOTCENTER.fits'
     im=readfits(file)
     l=size(im,/dimensions)
     n=l(2)
     ;..................................
     openw,33,'detected_shifts.dat'
     for i=0,n-1,1 do begin
     out=reform(im(*,*,i))
     if (i le 9) then mnumname='0'+string(i)
     if (i gt 9) then mnumname=string(i)
     fname=strcompress('DATA/imagetouse'+mnumname+'.fit',/remove_all)
     writefits,fname,out
     printf,33,format='(2(1x,f5.1),1x,a)',randomn(seed,2),fname
     endfor
     close,33
     return
     end

     PRO get_mask2,nfiles,im,dx,dy,mask
     print,'dx,dy:',dx,dy
     ; uses the shifting edges as the definition of the mask
     l=size(im,/dimensions)
     nx=l(0)
     ny=l(1)
     mask=fix(im)*0B+1B
     if (dx gt 0) then mask(0:dx-1,*)=0B
     if (dx le 0) then mask(nx-1+dx:nx-1,*)=0B
     if (dy gt 0) then mask(*,0:dy-1)=0B
     if (dy le 0) then mask(*,ny-1+dy:ny-1)=0B
     return
     end


     PRO get_mask3,nfiles,im,x,y,mask
     ; uses the parts of each image that are above a threshold as the mask
     mask=im*0B
     imlim=20000
; get rid of the sky
     mask(where(im gt imlim))=1B
; add an edge-omitter
;    mask(where(sobel(im) gt max(sobel(im))*0.1))=0B
; erode the mask
;    s=REPLICATE(1, 3, 3)
;    mask=erode(erode(mask,s),s)
     return
     end

 ;-------------------------------------------------------------------------
 ; code to apply Chae's method to dithered images
 ;-------------------------------------------------------------------------
 spawn,'rm DATA/*'
 for its=17,17,1 do begin
     openw,45,'results_gaincalib.dat'
 print,'Starting getting images...'
 bias=readfits('../superbias.fits')
 bias=bias*0.0
 ;bias=readfits('../DAVE_BIAS.fits')
 get_images_single,n,bias
 ;get_images_single_b,n,bias
 print,'Done getting images...'
 ; get the (known) shifts of the images and their names
 openr,11,'detected_shifts.dat'
 ic=0
 while (not eof(11)) do begin
 a=0 & b=0 & s=''
 readf,11,a,b,s
 s=strtrim(s,2)
 if (ic eq 0) then begin
 x=a
 y=b
 files=s
 endif
 if (ic gt 0) then begin
 x=[x,a]
 y=[y,b]
 files=[files,s]
 endif
 ic=ic+1
 endwhile
 close,11
 nfiles=n_elements(files)
 ;
 pedestal=50 ; small pedestal to avoid NaN during log
 if_restore=0
 if (if_restore eq 1) then begin
     restore,'results.sav' 
     endif else begin
     for ifil=0,nfiles-1,1 do begin
         subim=readfits(files(ifil))+pedestal
;        get_mask2,nfiles,subim,x(ifil),y(ifil),mask
         get_mask3,nfiles,subim,x,y,mask
	 go_normalize_with_mask,subim,ifil,mask
         if (ifil eq 0) then logimages=alog10(subim)
         if (ifil gt 0) then logimages=[[[logimages]],[[alog10(subim)]]]
         if (ifil eq 0) then mask_stack=mask
         if (ifil gt 0) then mask_stack=[[[mask_stack]],[[mask]]]
         endfor
     endelse
 ;
         mask=mask_stack
 endmask=avg(mask,2) gt .2
 ;
 !P.MULTI=[0,1,1]
 set_plot,'X'
 logflat = gaincalib_hgl(logimages, x, y, object=object,c=c,maxiter=its,mask=mask)
 ;logflat = gaincalib(logimages, x, y, object=object,c=c,maxiter=its,shift_flag=1,mask=mask)
 !P.MULTI=[0,2,2]
 set_plot,'ps'
 device,/landscape,filename=strcompress('idl_'+string(its)+'.ps',/remove_all)
 surface,logflat,title='logflat at N='+string(its)+' iterations.'
 surface,object,title='log object at N='+string(its)+' iterations.'
 plot,c,xtitle='Iterations',ytitle='C',title='at N='+string(its)+' iterations.'
 plot,x,y,psym=7,xtitle='Shifts in X',ytitle='Shifts in Y'
 device,/close
 ;-------------
 save,logflat,object,logimages,x,y,c,filename='results.sav'
 ;
 writefits,'mask.fits',mask
 writefits,'endmask.fits',endmask
 object=10^(object)
 writefits,'object.fits',object*endmask
 flat=10^(logflat)
 writefits,'flat.fits',flat*endmask
 print,'S/N in flat:',stddev(flat(where(endmask eq 1)))/mean(flat(where(endmask eq 1)))*100.0,' in %.'
 print,'(max-min)/mean in flat, in pct:',(max(flat(where(endmask eq 1)))-min(flat(where(endmask eq 1))))/mean(flat(where(endmask eq 1)))*100.0
 printf,45,n,stddev(flat(where(endmask eq 1)))/mean(flat(where(endmask eq 1)))*100.0
 ;
 openw,33,'output_shifts.dat'
 for i=0,nfiles-1,1 do begin
     printf,33,x(i),y(i)
     endfor
 close,33
 close,45
 endfor	; end of its loop
 end
