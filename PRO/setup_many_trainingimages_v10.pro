PRO get_the_libration_information,lib1,lib2,lib3
get_lun,uyfyrtd6345fvgw
openr,uyfyrtd6345fvgw,'libration_info.dat'
 readf,uyfyrtd6345fvgw,format='(f15.7,3(1x,f9.4))',JD, lib1,lib2,lib3
close,uyfyrtd6345fvgw
free_lun,uyfyrtd6345fvgw
return
end

PRO MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun,obsname,distance
;-----------------------------------------------------------------------
; Set various constants.
;-----------------------------------------------------------------------
RADEG  = 180.0/!PI
DRADEG = 180.0D/!DPI
AU = 149.6d+6       ; mean Sun-Earth distance     [km]
Rearth = 6365.0D    ; Earth radius                [km]
Rmoon = 1737.4D     ; Moon radius                 [km]
Dse = AU            ; default Sun-Earth distance  [km]
Dem = 384400.0D     ; default Earth-Moon distance [km]
MOONPOS, jd, ra_moon, DECmoon, dis
distance=dis/Rearth
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
SUNPOS, jd, ra_sun, DECsun
eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname
RAdiff = ra_moon - ra_sun
sign = +1
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
return
end
PRO get_two_synthetic_images,JD,im1,im2,mixedimageheader
 ; Generate two FITS images of the Moon for the given JD with Earth albedo 0 and 1
 get_lun,hjkl
 openw,hjkl,'JDtouseforSYNTH_117'
 printf,hjkl,format='(f15.7)',JD
 close,hjkl
 free_lun,hjkl
 ; set up albedo 0
 get_lun,hjkl
 openw,hjkl,'single_scattering_albedo.dat'
 printf,hjkl,0.0
 close,hjkl
 free_lun,hjkl
 ;...get the image
 spawn,'idl go_get_particular_synthimage_227.pro';,/NOSHELL
 im1=readfits('ItellYOUwantTHISimage.fits',/silent)
 ;writefits,'im1_justaftercreation.fits',im1
 ; set up for albedo 1.0
 get_lun,hjkl
 openw,hjkl,'single_scattering_albedo.dat'
 printf,hjkl,1.0
 close,hjkl
 free_lun,hjkl
 ;...get the image
 spawn,'idl go_get_particular_synthimage_227.pro';,/NOSHELL
 im2=readfits('ItellYOUwantTHISimage.fits',/silent,mixedimageheader)
 ;writefits,'im2_justaftercreation.fits',im2
 return
 end
 
 
 
 
 
 
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
 ; V10. Quite like v9 buta lso loops over JD
 close,/all
 pathDTU='/media/pth/874fb68e-7a8c-484c-bfce-2b002f8e81b8/DTUimages6/'
;pathDTU='/net/isilon/ifs/arch/home/pth/DTUimages3/'
 nims=150000L
 nrepeats=123
 eshine=1e-11;max(im1)/5000.0
 close,/all
 alfamin=1.4
 alfamax=3.0/1.61
 albedomin=0.1
 albedomax=0.5
 pedestalmin=eshine/4.
 pedestalmax=eshine*4.
 jd1=julday(11,11,2011,11,11,11.0d0)
 jd2=jd1+30.0d0
 for ims=0L,float(nims)/nrepeats-1,1 do begin
     jd=randomu(seed)*(jd2-jd1)+jd1
     get_two_synthetic_images,JD,im1,im2,mixedimageheader
     get_the_libration_information,lib1,lib2,lib3
;print,lib1,lib2,lib3
;ajhgfc=get_kbrd()
     alfa=randomu(seed)*(alfamax-alfamin)+alfamin
     writefits,'im0_org_s.fits',im1
     writefits,'im1_org_s.fits',im2
     print,'---------------------------------------'
     str="./justconvolve im0_org_s.fits im0_c.fits "+string(alfa)
     spawn,str
     im0_c=readfits('im0_c.fits')
     str="./justconvolve im1_org_s.fits im1_c.fits "+string(alfa)
     spawn,str
     im1_c=readfits('im1_c.fits')
     MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun,'DMI',distance
     for ialbedo=0,nrepeats-1,1 do begin
     pedestal=(pedestalmax-pedestalmin)*randomu(seed)+pedestalmin
     albedo=(albedomax-albedomin)*randomu(seed)+albedomin
     iim=im1_c*albedo+im0_c*(1.-albedo) + pedestal
     iim=iim/max(iim)*55000.0d0
     im=iim
     fname=string(JD,format='(f15.7)')+'_'+string(alfa,format='(f12.8)')+'_'+string(pedestal*1e10,format='(f12.8)')+'_'+string(albedo,format='(f12.8)')+'.fits'
     fname=strcompress(pathDTU+fname,/remove_all)
     print,fname
; generate a FITS file header with lunar phase angle
     mkhdr,newheader,im
     sxaddpar, newheader, 'PHASE', phase_angle_M, 'Lunar phase angle'
     sxaddpar, newheader, 'PEDESTAL', pedestal*55000.0, 'Sky offset'
     sxaddpar, newheader, 'ALPHA', alfa, 'PSF parameter'
     sxaddpar, newheader, 'ALBEDO', albedo, 'Terrestrial Albedo'
     sxaddpar, newheader, 'JD', jd, 'Julian Day'
     sxaddpar, newheader, 'DISTANCE', distance, 'Moon-Earth distance in Earth radii'
     sxaddpar, newheader, 'lib1', lib1, 'latitude libration'
     sxaddpar, newheader, 'lib2', lib2, 'longitude libration'
     sxaddpar, newheader, 'lib3', lib3, 'PA libration'
     writefits,strcompress(fname,/remove_all),im,newheader
	endfor ; end of ialbedo loop
     endfor	; end ims loop
 print,'---------------------------------------'
 close,22
 end
