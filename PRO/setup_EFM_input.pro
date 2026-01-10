PRO get_mask,im,x0,y0,radius,mask
 common sizes,l,x,y
 nx=l(0) & ny=l(1) & mask=fltarr(nx,ny)
 ; build a 1/0 mask that is a circle (center x0,y0) and radius r with 1's outside radius and 0's inside
 rad=sqrt((x-x0)^2+(y-y0)^2)
 idx=where(rad gt radius)
 smooim=smooth(abs(im),11,/edge_truncate)
 mask(idx)=1./smooim(idx)^2
 mask(*,y0+radius*0.6:511)=0
 mask(*,0:y0-radius*0.6)=0
 return
 end
 
 PRO gomakethemask,outpathname,im,x0,y0,radius,mask
 common sizes,l,x,y
 get_mask,im,x0,y0,radius,mask
 writefits,strcompress(outpathname+'mask.fits',/remove_all),mask
 return
 end
 
 PRO get_EXPOSURE,h,expt
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 expt=float(date_str)
 return
 end
 
 
 PRO gosetupotions,outpathname,x0,y0,radius,cg_x,cg_y,iflag
 ; will print a options.nml file appropriate for the current imge
 ; if setup was successful then iflag is not 314 upon exit
 iflag=314
 waval=9
 wbval=9
 help,x0,y0,radius,cg_x,cg_y
 ; for DS on left and BS on right:
 if (cg_x gt x0) then begin
     aval=fix((x0-radius)/2.)
     bval=fix(x0+radius-40)
     if (aval-waval ge 0) then iflag=2
     endif
 if (cg_x le x0) then begin
     aval=fix((x0+radius+512)/2.)
     bval=fix(x0-radius-40)
     if (aval+waval le 511) then iflag=2
     endif
 cval=fix(y0)
 ;
 openw,82,outpathname+'options.nml'
 printf,82,'&OPTIONLIST'
 printf,82,''
 printf,82,"fpsf    = 'PSF_fromHalo_1536.fits'"
 printf,82,"ftarget = 'target.fits'"
 printf,82,"fmask   = 'mask.fits'"
 printf,82,'a       = '+string(aval)
 printf,82,'b       = '+string(bval)
 printf,82,'c       = '+string(cval)
 printf,82,'wa      = '+string(waval)
 printf,82,'wb      = '+string(wbval)
 printf,82,'LTRIP   = 7'
 printf,82,'ntrips  = 9'
 printf,82,'alfalo  =        1.0000000'
 printf,82,'alfahi  =        2.0000000 /'
 close,82
 return
 end
 
 
 
 
 
 
 
 
 
 ;------------------------------------------------------------------------
 ; Version 1. Code that sets up the necessary inputs for the EFM method
 ;
 ;------------------------------------------------------------------------
 common sizes,l,x,y
 ; set path to images to be used are stored
 jd='JD2456007'
 jd='JD2456002'
 inpath='/media/SAMSUNG/DARKCURRENTREDUCED/'
 path=strcompress(inpath+JD+'/',/remove_all)
 ; find the files
 spawn,'ls '+path+'*.fits | grep -v CLEANED > allfiles'
 openw,34,'temp2.dat'
 openw,33,'temp.dat'
 openr,1,'allfiles'
 ic=0
 ; test for direcories and set up the files
 if (file_test('FORCRAY/'+JD+'/') ne 1) then begin
     spawn,'mkdir FORCRAY/'+JD+'/'
     endif else begin
     spawn,'rm -r FORCRAY/'+JD+'/*'
     endelse
 while not eof(1) do begin
     set_plot,'x'
     filname=''
     readf,1,filname
     im=readfits(filname,h,/silent) & l=size(im,/dimensions)
     ; generate the x and y arrays for the image
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
     
     get_EXPOSURE,h,expt
     gofindradiusandcenter,im,x0,y0,radius
     cgfinder,im,cg_x,cg_y
     tvscl,im
     outpathname=strcompress('FORCRAY/'+JD+'/EFM_IMAGE'+string(ic)+'/',/remove_all)
     inf=file_test(outpathname)
     if (file_test(outpathname) ne 1) then begin
         ; create the numbered subdirectory if it does note xist
         spawn,'mkdir '+outpathname
         endif else begin
         ; if it exists then empty it
         spawn,'rm '+outpathname+'*'
         endelse
     ; print the options into the created directory
     gosetupotions,outpathname,x0,y0,radius,cg_x,cg_y,iflag
     ; generate the mask and place it in the created directory
     gomakethemask,outpathname,im,x0,y0,radius,mask
     ; cp the image to target.fits
     spawn,'cp '+filname+' '+outpathname+'target.fits'
     ; write an info file into the directory
     openw,76,strcompress(outpathname+'info.txt',/remove_all)
     printf,76,filname 
     close,76
     ; print some stats about the image
     print,format='(5(1x,g14.7),1x,i4)',total(im,/double)/expt,stddev(im)/total(im),x0,y0,radius,iflag
     printf,format='(5(1x,g14.7),1x,i4)',33,total(im,/double)/expt,stddev(im)/total(im),x0,y0,radius,iflag
     printf,format='(5(1x,g14.7),1x,i4,1x,a)',34,total(im,/double)/expt,stddev(im)/total(im),x0,y0,radius,iflag,filname
     ic=ic+1
     endwhile
 close,1
 close,33
 close,34
 set_plot,'ps'
 device,filename=strcompress('diagnostic_plot.ps',/remove_all)
 data=get_data('temp.dat')
 !P.MULTI=[0,2,2]
 flux=reform(data(0,*))
 SNR=reform(data(1,*))
 x0=reform(data(2,*))
 y0=reform(data(3,*))
 radius=reform(data(4,*))
 plot,SNR,ystyle=3,ytitle='SNR',xstyle=3
 plot,flux,ystyle=3,ytitle='flux',xstyle=3
 plot,x0,y0,psym=7,ystyle=3,xstyle=3,xtitle='x!d0!n',ytitle='y!d0!n'
 plot,radius,ystyle=3,ytitle='radius',xstyle=3
 device,/close
 spawn,'mv diagnostic_plot.ps '+strcompress('FORCRAY/'+JD+'/',/remove_all)
 spawn,'mv temp2.dat '+'FORCRAY/'+JD+'/alimagesinfo.txt'
 end
