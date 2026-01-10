PRO gorotateimage,im
angle=(randomu(seed)-0.5)*15
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
 im=alog10(im_in)
 row=[]
 row2=reform(congrid(im,n,n),n*n)
 row=[row2,albedo]
 help,row
 return
 end
 
 
 
 ;====================================
 ; code to set up a lot of data from model images
 ; output is suitable for a linear regression, as well as forest.py
 ; V6. Like V5, but does not 'squish' the data
 
 im0=readfits('im1.fits')
 im1=readfits('im2.fits')
 eshine=1e-11;max(im1)/5000.0
;im0=shift(im0,40,-50)	; use these shifts to enable orientation-identification later
;im1=shift(im1,40,-50)
 writefits,'im0_org_s.fits',im0;/total(im0)
 writefits,'im1_org_s.fits',im1;/total(im1)
 close,/all
 n=25	; make nxn boxes across the image
 nims=10000L
 openw,44,'n.dat'
 printf,44,n
 close,44
 fmtstr='('+string(n*n+1)+'(f11.5)'+')'
 openw,2,'/data/OUTPUT/TABLE_TOTRAIN.DAT'
 for ims=0L,nims-1,1 do begin
     alfamin=1.4
     alfamax=3.0/1.61
     alfa=randomu(seed)*(alfamax-alfamin)+alfamin
     pedestalmin=eshine/20.
     pedestalmax=eshine*4.
     pedestal=(pedestalmax-pedestalmin)*randomu(seed)+pedestalmin
     albedomin=0.2
     albedomax=0.5
     albedo=(albedomax-albedomin)*randomu(seed)+albedomin
     print,'---------------------------------------'
     str="./justconvolve im0_org_s.fits im0_c.fits "+string(alfa)
     spawn,str
     im0_c=readfits('im0_c.fits')
     str="./justconvolve im1_org_s.fits im1_c.fits "+string(alfa)
     spawn,str
     im1_c=readfits('im1_c.fits')
     print,alfa,albedo,pedestal
     iim=im1_c*albedo+im0_c*(1.-albedo) + pedestal
     iim=iim/total(iim,/double)
;    gorotateimage,iim
     goshiftimage,iim,n
;---------------reducing the image to blocks and writing the blcosk to file ------------------
; write image as is
     getrow,n,iim,albedo,row
     printf,2,row,format=fmtstr
; write image rotated 90 degress ...
     getrow,n,rotate(iim,90),albedo,row
     printf,2,row,format=fmtstr
; write image rotated 180 degress ...
     getrow,n,rotate(iim,180),albedo,row
     printf,2,row,format=fmtstr
; write image rotated 270 degress ...
     getrow,n,rotate(iim,270),albedo,row
     printf,2,row,format=fmtstr
;--------------- END of reducing the image to blocks and writing the blcosk to file ----------
     endfor	; end ims loop
 print,'---------------------------------------'
 close,2
 ; now scale the data for practical use in e.g. forest.py code
 nsquaredstr=string(n*n)
 data=get_data('/data/OUTPUT/TABLE_TOTRAIN.DAT')
 print,'Description of data: '
 help,data
 openw,2,'scaled_array.dat'
 printf,2,format='('+nsquaredstr+'(f12.6,","),f12.6)',data
 close,2
 print,'Huge table now at /data/OUTPUT/TABLE_TOTRAIN.DAT ... '
 print,'... and in scaled_array.dat'
 print,'Now use the regress code .. or forest.py '
 end
