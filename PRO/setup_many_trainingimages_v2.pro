PRO squish,array,mingoal,maxgoal
 l=size(array,/dimensions)
 ncol=l(0)
 nrows=l(1)
 minval=min(array(0:ncol-2,*))
 maxval=max(array(0:ncol-2,*))
 print,'Original min,max: ',minval,maxval
 ;
 scaledarray=array(0:ncol-2,*)
 scaledarray=(scaledarray-minval)/(maxval-minval)
 array(0:ncol-2,*)=scaledarray
 minval=min(array(0:ncol-2,*))
 maxval=max(array(0:ncol-2,*))
 print,'Scaled min,max: ',minval,maxval
 array(ncol-1,*)=fix(array(ncol-1,*)*1000)
 col=array(0,*)*0+1
 array=[col,array]
 return
 end

 PRO getrow,n,im_in,albedo,row
 im=alog10(im_in)
 wid=512
 nwid=fix(wid/float(n))
 row=[]
 for i=0,n-1,1 do begin
     ; ]  [
     for j=0,n-1,1 do begin
         from_i=i*nwid
         to_i=(i+1)*nwid
         from_j=j*nwid
         to_j=(j+1)*nwid
         subim=im(from_i:to_i,from_j:to_j)
         row=[row,mean(subim)]
         endfor
     endfor
 row=[row,albedo]
 return
 end
 
 
 
 ;====================================
 ; code to set up a lot of data from model images
 ; outputis suitable for a linear regression, as well as forest.py
 ; V2. Pedestal term added
 
 im0=readfits('im1.fits')
 im1=readfits('im2.fits')
 eshine=1e-11;max(im1)/5000.0
 im0=shift(im0,40,-50)	; use these shifts to enable orientation-identification later
 im1=shift(im1,40,-50)
 writefits,'im0_org_s.fits',im0;/total(im0)
 writefits,'im1_org_s.fits',im1;/total(im1)
 close,/all
 n=20	; make nxn boxes across the image
 openw,44,'n.dat'
 printf,44,n
 close,44
 fmtstr='('+string(n*n+1)+'(f11.5)'+')'
 openw,2,'/data/pth/TABLE_TOTRAIN.DAT'
 alfamin=1.4
 alfamax=3.0/1.61
 alfastep=(alfamax-alfamin)/15.
 pedestalmin=eshine/10.
 pedestalmax=eshine*2.
 pedestalstep=eshine/7.
 albedomin=0.2
 albedomax=0.5
 albedostep=(albedomax-albedomin)/22.
 for alfa=alfamin,alfamax,alfastep do begin
     print,'---------------------------------------'
     str="./justconvolve im0_org_s.fits im0_c.fits "+string(alfa)
     spawn,str
     im0_c=readfits('im0_c.fits')
     str="./justconvolve im1_org_s.fits im1_c.fits "+string(alfa)
     spawn,str
     im1_c=readfits('im1_c.fits')
     for albedo=albedomin,albedomax,albedostep do begin
         for pedestal = pedestalmin,pedestalmax,pedestalstep do begin
             print,alfa,albedo,pedestal
             iim=im1_c*albedo+im0_c*(1.-albedo) + pedestal
             iim=iim/total(iim,/double)
             getrow,n,iim,albedo,row
             printf,2,row,format=fmtstr
             endfor	; end pedestal loop
         endfor	; end albedoloop
     endfor	; end alfa loop
 print,'---------------------------------------'
 close,2
 ; now scael the data for practical use in e.g. forest.py code
 nstrplus1=string(n*n+1)
 data=get_data('/data/pth/TABLE_TOTRAIN.DAT')
 squish,data,0,1
 openw,2,'scaled_array.dat'
 printf,2,format='('+nstrplus1+'(f12.5,","),i4)',data
 close,2
 print,'Now use the regress code .. or forest.py '
 end
