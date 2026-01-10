 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end
 
 PRO save_a_STRING_to_a_named_file,str,filename
 get_lun,hjkl
 openw,hjkl,filename
 printf,hjkl,str
 close,hjkl
 free_lun,hjkl
 return
 end
 
 
 PRO save_a_number_to_a_named_file,number,filename
 get_lun,hjkl
 openw,hjkl,filename
 printf,hjkl,number
 close,hjkl
 free_lun,hjkl
 return
 end
 
 
 ;=========================================================
 ; code to generate many ideal images with different settings
 ; especially different BRDFs and albedo maps
 ;=========================================================
 close,/all
 ;
 openr,1,'list.txt'
 while not eof(1) do begin
     str=''
     readf,1,str
	if (str eq 'stop') then exit
     im=readfits(str,h,/silent)
     ; get the JD
     jd=double(strmid(str,strpos(str,'24'),15))
;    for usrsw3=300,400,100 do begin
     for usrsw3=300,300,100 do begin
     for iearth_BRDF=100,100,100 do begin
;    for iearth_BRDF=100,200,100 do begin
         ;usrsw3=300 ; this implies the 'new Hapke 63' BRDF model
         ;usrsw3=400 ; this implies the 'Hapke-X' BRDF model
         ;iearth_BRDF=100 implies earth BRDF = Lambertian
         ;iearth_BRDF=200 implies earth BRDF = Lommel-Seeliger
         for alMPsw=1,1,1 do begin
;        for alMPsw=1,3,1 do begin
             ;alMPsw=1       ; this is the scaled HIRES Clementine map (select UNscaling inside eshine_21_core.pro)
             ;alMPsw=2       ; this is the unscaled UVVIS CLementine map
             ;alMPsw=3       ; this is the LRO maps
	     moon_BRDF=usrsw3+alMPsw
             earth_BRDF=iearth_BRDF
             ;....................
             save_a_number_to_a_named_file,usrsw3,'userswitch314.txt'
             save_a_number_to_a_named_file,alMPsw,'albedouserswitch.txt'
             save_a_number_to_a_named_file,moon_BRDF,'moon_BRDF.txt'
             save_a_number_to_a_named_file,earth_BRDF,'earth_BRDF.txt'
             if (moon_BRDF eq 301 and earth_BRDF eq 100) then path='/data/pth/UNIVERSALSETOFMODELS/newH-63_HIRESscaled_LA/'
             if (moon_BRDF eq 302 and earth_BRDF eq 100) then path='/data/pth/UNIVERSALSETOFMODELS/newH-63_UVVISnoscale_LA/'
             if (moon_BRDF eq 303 and earth_BRDF eq 100) then path='/data/pth/UNIVERSALSETOFMODELS/newH-63_LRO_LA/'
             if (moon_BRDF eq 401 and earth_BRDF eq 100) then path='/data/pth/UNIVERSALSETOFMODELS/H-X_HIRESscaled_LA/'
             if (moon_BRDF eq 402 and earth_BRDF eq 100) then path='/data/pth/UNIVERSALSETOFMODELS/H-X_UVVISnoscale_LA/'
             if (moon_BRDF eq 403 and earth_BRDF eq 100) then path='/data/pth/UNIVERSALSETOFMODELS/H-X_LRO_LA/'
             if (moon_BRDF eq 301 and earth_BRDF eq 200) then path='/data/pth/UNIVERSALSETOFMODELS/newH-63_HIRESscaled_LS/'
             if (moon_BRDF eq 302 and earth_BRDF eq 200) then path='/data/pth/UNIVERSALSETOFMODELS/newH-63_UVVISnoscale_LS/'
             if (moon_BRDF eq 303 and earth_BRDF eq 200) then path='/data/pth/UNIVERSALSETOFMODELS/newH-63_LRO_LS/'
             if (moon_BRDF eq 401 and earth_BRDF eq 200) then path='/data/pth/UNIVERSALSETOFMODELS/H-X_HIRESscaled_LS/'
             if (moon_BRDF eq 402 and earth_BRDF eq 200) then path='/data/pth/UNIVERSALSETOFMODELS/H-X_UVVISnoscale_LS/'
             if (moon_BRDF eq 403 and earth_BRDF eq 200) then path='/data/pth/UNIVERSALSETOFMODELS/H-X_LRO_LS/'
             ;-----------------------------
             save_a_STRING_to_a_named_file,'_V_','FILTER.txt'
             ;-----------------------------
             ; put the JD into a file
             get_lun,hjkl
             openw,hjkl,'usethisJD'
             printf,hjkl,format='(f15.7)',JD(0)
             close,hjkl
             free_lun,hjkl
 	; set up terrestrial albedo 1.0
 	save_a_number_to_a_named_file,1.0,'single_scattering_albedo.dat'
             ;...get the image
             spawn,'rm -f ItellYOUwantTHISimage.fits'
             spawn,'rm -f lonlatpairItellYOUwantTHISimage.fits'
             spawn,'idl go_get_particular_synthimage_118.pro'
             im=readfits('ItellYOUwantTHISimage.fits',h,/silent)
             lonlatim=readfits('lonlatpairItellYOUwantTHISimage.fits',header55,/silent)
	     im=[[[im]],[[lonlatim]]]	; build an image containing lon/lat images
             writefits,strcompress(path+'ideal_'+string(JD,format='(f15.7)')+'_SSA_1p0.fits',/remove_all),im,header55
             ;-----------------------------
 	; set up terrestrial albedo 0.0
 	save_a_number_to_a_named_file,0.0,'single_scattering_albedo.dat'
             ;...get the image
             spawn,'rm -f ItellYOUwantTHISimage.fits'
             spawn,'rm -f lonlatpairItellYOUwantTHISimage.fits'
             spawn,'idl go_get_particular_synthimage_118.pro'
             im=readfits('ItellYOUwantTHISimage.fits',h,/silent)
             writefits,strcompress(path+'ideal_'+string(JD,format='(f15.7)')+'_SSA_0p0.fits',/remove_all),im,header55
             ;-----------------------------
	     print,'path: ',path
             endfor
             endfor
         endfor
     endwhile
 close,1
 end
