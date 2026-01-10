PRO     getsomeDSphotometry,im,x0,y0,radius,phot,err
 nx=512
 ny=512
x0=256
y0=256
meshgrid,nx,ny,x,y
radius_surface=sqrt((x-x0)^2+(y-y0) ^2)
idx=where(radius_surface lt radius and x lt x0-0.9*radius)
phot=mean(im(idx),/NaN)
err=stddev(im(idx),/NaN)
return
end

PRO parseit,str,B_JD_number,V_JD_number
 bits=strsplit(str,' ',/extract)
 Vbit=bits(1)
 Bbit=bits(2)
 morebits=strsplit(Vbit,'_',/extract)
 V_JD_number=morebits(3)
 morebits2=strsplit(Bbit,'_',/extract)
 B_JD_number=morebits2(3)
 return
 end
 
 PRO get_mask,x0,y0,radius,mask
 ; build a 1/NaN  mask that is a circle (center x0,y0) and radius 
 ; r with 1's outside radius and Nan's inside
 nx=512
 ny=512
 mask=fltarr(nx,ny)
 for i=0L,nx-1,1 do begin
     for j=0L,ny-1,1 do begin
         rad=sqrt((i-x0)^2+(j-y0)^2)
         if (rad le radius) then mask (i,j)=1 else mask(i,j)=!values.f_nan
         endfor
     endfor
 return
 end
 
 PRO get_airmass_fromJD,JD,azimuth,am
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 ; get the airmass
 moonpos, JD, RAmoon, DECmoon
 am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
 am=am(0)
 print,'Airmass: ',am
 end
 
 FUNCTION get_JD_from_filename,name
 liste=strsplit(name,'_',/extract)
 idx=strpos(liste,'24')
 ipoint=where(idx ne -1)
 JD=double(liste(ipoint))
 return,JD
 end
 
 PRO iterativelyfindBandV,idx,Binst,Vinst,am_B,am_V,B,V,BminusV
 common results,deltaBmV_Moon,bmv
 niter=10
 kB=0.15
 kV=0.1
; La Silla values
 kB=0.2
 kV=0.11
; Mt Palomar values:
 kB=0.256
 kV=0.151
; Krisciunas : http://adsabs.harvard.edu/abs/1987PASP...99..887K
kB=0.19
kV=0.11
 print,'iterating B-V ...'
 V=dblarr(512,512)
 B=dblarr(512,512)
 for i=0,511,1 do begin
 for j=0,511,1 do begin
 B(i,j)=!values.f_nan
 V(i,j)=!values.f_nan
 bmv=0.92
 if (finite(Binst(i,j))*finite(Vinst(i,j)) eq 1) then begin
 oldbmv=1e32
 for iter=0,niter-1,1 do begin
     V(i,j) = Vinst(i,j) + 15.07 - 0.05*bmv - kV*am_V
     B(i,j) = Binst(i,j) + 14.75 + 0.21*bmv  - kB*am_B
     bmv=B(i,j)-V(i,j)
 ;    print,i,j,bmv,bmv-oldbmv
     oldbmv=bmv
     endfor
if (abs(bmv-oldbmv) gt 1e-5) then begin
print,i,j,' did not converge!'
stop
endif
 endif
 endfor
 endfor
 BminusV=B-V
 kdx=where(finite(B-V) eq 1)
 bmv=mean(BminusV(idx),/NaN)
 deltaBmV_Moon=bmv-0.642	; 0.642 comes from Holmberg et al MNRAS  367,, p. 449-453 (2006).
 ;print,'Since the Sun has B-V=0.642 and you have found that the BS B-V= ',bmv
 ;print,'we now know that one reflection from the Moon causes a reddening of: ',bmv-0.642
 return
 end
 
 PRO auto_align,im,head
 common masks,mask
 common disk,x0,y0,radius
 gofindradiusandcenter_fromheader,head,x0,y0,radius
 print,x0,y0,radius
 get_mask,256,256,radius,mask
 im=shift_sub(im,256-x0(0),256-y0(0))
 im=im*mask
 return
 end
 
 PRO gofindradiusandcenter_fromheader,header,x0,y0,radius
 ; Will take a header and read out DISCX0, DISCY0 and RADIUS
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCX0 not in header. Assigning dummy value'
     x0=256.
     endif else begin
     x0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCY0 not in header. Assigning dummy value'
     y0=256.
     endif else begin
     y0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     radius=float(strmid(header(jdx),11,19))
     endelse
 x0=x0(0)
 y0=y0(0)
 radius=radius(0)
 return
 end
 
 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 exptime=exptime(0)
 return
 end
 
 
 
 ; Version 2 - iterates on individual pixels to generate B-V
 ; code to generate B and V and B-V images from RAW and BBSOlin images in CUBES
 common results,deltaBmV_Moon,bmv
 common masks,mask
 common disk,x0,y0,radius
 openw,5,'Fits_about_Moon.txt'
 ;
 V_JD_number='2456015.7558321'
 B_JD_number='2456015.7533013'
 ; list with pairs of V and B images thata re close in time, and good:
 goodlist='BMINUSVWORKAREA/list_good_and_close_B_and_V_images'
 openr,82,goodlist
 while not eof(82) do begin
     print,'============================================================================'
     str=''
     readf,82,str
     parseit,str,B_JD_number,V_JD_number
     Vimname='/media/SAMSUNG/EARTHSHINE/CUBES/cube_MkIII_onealfa_'+V_JD_number+'_V_.fits'
     Bimname='/media/SAMSUNG/EARTHSHINE/CUBES/cube_MkIII_onealfa_'+B_JD_number+'_B_.fits'
     print,'V name: ',Vimname
     print,'B name: ',Bimname
     ; get the images
     Bcube=readfits(Bimname,Bhead)
     Vcube=readfits(Vimname,Vhead)
     ; get the JDs
     JD_B=get_JD_from_filename(Bimname)
     JD_V=get_JD_from_filename(Vimname)
     ; get the airmasses
     get_airmass_fromJD,JD_B,azimuth,am_B
     get_airmass_fromJD,JD_V,azimuth,am_V
     ; get the relevant images
     Braw=reform(Bcube(*,*,0))
     Vraw=reform(Vcube(*,*,0))
     BbbsoLIN=reform(Bcube(*,*,2))
     VbbsoLIN=reform(Vcube(*,*,2))
     ; shift the images to disc centre
     auto_align,Braw,Bhead
     auto_align,BbbsoLIN,Bhead
     auto_align,Vraw,Vhead
     auto_align,VbbsoLIN,Vhead
; generate ratio images
     B_ratioim=double(BbbsoLIN)/double(Braw)
     V_ratioim=double(VbbsoLIN)/double(Vraw)
     ; get the pointers that indicate the BS pixels
     idx=where(braw gt 0.1*max(braw(where(finite(braw) eq 1))))
     if (n_elements(idx) lt 100) then begin
         print,'Mask no good!'
         help,braw
         writefits,'help_braw.fits',braw
         stop
         endif
     ; get the exp times
     get_EXPOSURE,Bhead,Bexptime
     get_EXPOSURE,Vhead,Vexptime
     ; convert to inst mag images
     Braw=-2.5*alog10(Braw/Bexptime)
     BbbsoLIN=-2.5*alog10(BbbsoLIN/Bexptime)
     Vraw=-2.5*alog10(Vraw/Vexptime)
     VbbsoLIN=-2.5*alog10(VbbsoLIN/Vexptime)
     ; convert to B and V mag images
     iterativelyfindBandV,idx,Braw,Vraw,am_B,am_V,B,V,BminusV1
     outpath='BmVimages/'
     writefits,outpath+B_JD_number+'_Braw.fits',B
     writefits,outpath+V_JD_number+'_Vraw.fits',V
     writefits,outpath+B_JD_number+'_'+V_JD_number+'_Braw_minus_Vraw.fits',BminusV1
     iterativelyfindBandV,idx,BbbsoLIN,VbbsoLIN,am_B,am_V,B,V,BminusV2
     writefits,outpath+B_JD_number+'_BbbsoLIN.fits',B
     writefits,outpath+V_JD_number+'_VbbsoLIN.fits',V
     writefits,outpath+B_JD_number+'_'+V_JD_number+'_BbbsoLIN_minus_VbbsoLIN.fits',BminusV2
     writefits,outpath+B_JD_number+'_'+V_JD_number+'BmV_raw_BBSOlin.fits',[BminusV1,BminusV2]
     writefits,outpath+B_JD_number+'_B_ratioimage_BBSOlin_over_raw.fits',B_ratioim*mask
     writefits,outpath+V_JD_number+'_V_ratioimage_BBSOlin_over_raw.fits',V_ratioim*mask
     mask(idx)=2
     writefits,outpath+'mask_'+V_JD_number+'.fits',mask
     getsomeDSphotometry,BminusV2,x0,y0,radius,tokenDSBmVmeanvalue,err
     ;
     printf,5,format='(2(f15.7,1x),4(f9.4,1x))',B_JD_number,V_JD_number,deltaBmV_Moon,bmv,tokenDSBmVmeanvalue,err
     print,format='(2(f15.7,1x),4(f9.4,1x))',B_JD_number,V_JD_number,deltaBmV_Moon,bmv,tokenDSBmVmeanvalue,err
     endwhile
 close,82
 close,5
 end
