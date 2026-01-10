PRO manual_align,im,reference,offset,diff
 k=0
 l=size(im,/dimensions)
 Nx=l(0)*1.0
 Ny=l(1)*1.0
 offset = alignoffset(im, reference, corr)
 offset=[offset(0),offset(1),0.0]
 ; First get rough offset from 'alignoffset'
 shifted_im=shift_sub(im,-offset(0),-offset(1))
 key='q'
 print,'Press R,L,u,d,l or r key - q to quit'
 print,'R,L for rotation and u,d,l,r for position'
 start:
 key=get_kbrd()
 print,key
 dx=0.0
 dy=0.0
 da=0.0
 da=0.0
 if (key eq 'u') then begin
     dy=0.1
     endif	
 if (key eq 'd') then begin
     dy=-0.1
     endif	
 if (key eq 'r') then begin
     dx=0.1
     endif	
 if (key eq 'l') then begin
     dx=-0.1
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
 window,2,xsize=512,ysize=512
 diff=(float(shifted_im)-float(reference))/float(shifted_im)
 ;diff=(float(shifted_im)-float(reference))/float(reference)
 print,'Sum of square diff: ',total(diff^2,/NaN)
 window,2,xsize=512,ysize=512
 loadct,13
 tvscl,smooth(hist_equal(diff),7,/edge_truncate)
 window,1
 !P.MULTI=[0,1,2]
 plot,yrange=[-10,10],diff(*,256),xtitle='Column #',ystyle=3,xstyle=3
 plot,yrange=[-10,10],diff(256,*),xtitle='Row #',ystyle=3,xstyle=3
 if (key ne 'q') then goto, start
 reference=shifted_im
 return
 end
 
 im1=readfits('raw.fits')
 im1=im1/total(im1)
 im2=readfits('synth.fits')
 im2=im2/total(im2)
 manual_align,im2,im1,offset,diff
 end
