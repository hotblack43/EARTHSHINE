 PRO flipflopimage,im,iaction,flipflopped
 if (iaction eq 0) then flipflopped=im
 if (iaction eq 1) then flipflopped=rotate(im,1)
 if (iaction eq 2) then flipflopped=rotate(im,2)
 if (iaction eq 3) then flipflopped=rotate(im,3)
 return
 end
 
 PRO gorotateimage,im
 angle=(randomu(seed)-0.5)*2*180	; random angle between +/- 180
 ;angle=(randomu(seed)-0.5)*20	; random angle between +/- 1
 print,'Rotation angle:',angle
 im=rot(im,angle)
 return
 end
 
 PRO goshiftimage,im,n
 delta=512/float(n)
 x=(randomu(seed)-0.5)*2
 y=(randomu(seed)-0.5)*2
 im=shift(im,x*delta,y*delta)
 print,'Shifts:',x*delta,y*delta
 return
 end
 
 PRO getrow,n,im_in,albedo,row
 ; converst the 512x512 image into nxn squares (mean of)
 ; and places it all on a row, with 'albedo' at the end
 ; and takes the log10 to compress values
 ifwantPOISSON=0
 im=alog10(im_in)
 row=[]
 row2=reform(rebin(im,n,n),n*n)	; makes an average of whole box - 512 must be multiple of n
;row2=reform(congrid(im,n,n),n*n)	; uses sampling
 if (ifwantPOISSON eq 1) then begin
 stop
 for k=0,n_elements(row2)-1,1 do begin
	summed_Poiss=(512/n)^2*10^abs(row2(k))
	old=row2(k)
	row2(k)=alog10(randomu(seed,poisson=summed_Poiss,/double))   
;print,old,row2(k)
 endfor
 endif
 row=[row2,albedo]
 return
 end
 
 
 
 ;====================================
 ; Code to set up a lot of data from model images
 ; output is suitable for a linear regression, as well as forest.py
 ; V9. Uses REBIN instead of CONGRID (i.e. average instead of sample) and this forces block size to even fraction of 512
 close,/all
 im0=readfits('im1.fits')
 im1=readfits('im2.fits')
 eshine=1e-11;max(im1)/5000.0
 ;im0=shift(im0,40,-50)	; use these shifts to enable orientation-identification later
 ;im1=shift(im1,40,-50)
 writefits,'im0_org_s.fits',im0;/total(im0)
 writefits,'im1_org_s.fits',im1;/total(im1)
 close,/all
 n=8	; make nxn boxes across the image
; Note nm ust be 2^k   k=1,2,3,......
 nims=100000L	; make this many images, of these nims/nrepeats will hav eunique alpha values
 nrepeats=100.0d0
 get_lun,jhgfss
 openw,jhgfss,'n.dat'
 printf,jhgfss,n
 close,jhgfss
 free_lun,jhgfss
 fmtstr='('+string(n*n+1)+'(f11.5)'+')'
 spawn,"rm -f /data/OUTPUT/TABLE_TOTRAIN2b.DAT"
 openw,22,'/data/OUTPUT/TABLE_TOTRAIN2b.DAT'
 alfamin=1.4
 alfamax=3.0/1.61
 albedomin=0.2
 albedomax=0.5
 pedestalmin=eshine/20.
 pedestalmax=eshine*4.
 ic=0L
         pathDTU='/media/pth/874fb68e-7a8c-484c-bfce-2b002f8e81b8/DTUimages2/'
 for ims=0L,nims/nrepeats-1,1 do begin
     alfa=randomu(seed)*(alfamax-alfamin)+alfamin
     print,'---------------------------------------'
     str="./justconvolve im0_org_s.fits im0_c.fits "+string(alfa)
     spawn,str
     im0_c=readfits('im0_c.fits')
     str="./justconvolve im1_org_s.fits im1_c.fits "+string(alfa)
     spawn,str
     im1_c=readfits('im1_c.fits')
     for irepeat=0,nrepeats-1,1 do begin
         pedestal=(pedestalmax-pedestalmin)*randomu(seed)+pedestalmin
         albedo=(albedomax-albedomin)*randomu(seed)+albedomin
         print,ic,' of ',nims,alfa,albedo,pedestal,format='(i6,a,i6,3(1x,f12.7))'
         iim=im1_c*albedo+im0_c*(1.-albedo) + pedestal
         iim=iim/total(iim,/double)
         ;   goshiftimage,iim,n
;	for iaction=0,3,1 do begin
	 im=iim
;        flipflopimage,im,iaction,flipflopped
;	 im=flipflopped
;        gorotateimage,im
         fname=string(alfa,format='(f12.8)')+'_'+string(pedestal*1e10,format='(f12.8)')+'_'+string(albedo,format='(f12.8)')+'.fits'
	fname=strcompress(pathDTU+fname,/remove_all)
print,fname
         writefits,strcompress(fname,/remove_all),im
;---reduce the image to blocks and writing the blocks to file ------
         getrow,n,im,albedo,row
         printf,22,row,format=fmtstr
         ic=ic+1
	 endfor	; end iaction loop
;         endfor	; END of irepeats
     ;--------------- END of reducing the image to blocks 
     endfor	; end ims loop
 print,'---------------------------------------'
 close,22
 ; now scale the data for practical use in e.g. forest.py code
 nsquaredstr=string(n*n)
 data=get_data('/data/OUTPUT/TABLE_TOTRAIN2b.DAT')
 print,'Description of data: '
 openw,22,'scaled_array.dat'
 printf,22,format='('+nsquaredstr+'(f12.6,","),f12.6)',data
 close,22
 print,'Huge table now at /data/OUTPUT/TABLE_TOTRAIN2b.DAT ... '
 print,'... and in scaled_array.dat'
 print,'Now use the regress code .. or forest.py '
 end
