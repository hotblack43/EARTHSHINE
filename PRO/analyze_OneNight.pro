 PRO buildname,namein,basicname
 dotpos=strpos(namein,'.',/reverse_search)
 slashpos=strpos(namein,'/',/reverse_search)
 basicname=strmid(namein,slashpos+1,dotpos-slashpos-1)
 return
 end
 
 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 PRO go_mean_half_median,im,dark
 ; forms the mean of the middle median half of a stack of images
 l=size(im,/dimensions)
 dark=fltarr(l(0),l(1))
 for i=0,l(0)-1,1 do begin
     for j=0,l(1)-1,1 do begin
         line=im(i,j,*)
         line=line(sort(line))
         low=l(2)*0.25
         high=l(2)*0.75
         middlehalf=line(low:high)
         dark(i,j)=mean(middlehalf,/double)
         endfor
     endfor
 return
 end
 
 ifbuild_darks=0
 path='/media/LaCie/ASTRO/ANDOR/JD2455719/'
 if (ifbuild_darks eq 1) then begin
     print,'So, building darks ...'
     ; generate the 20ms dark frame
     files=file_search(path+'*dark*',/fold_case,count=n)
     print,files
     im=readfits('/media/LaCie/ASTRO/ANDOR/JD2455719/2455719.8333768DARK_Dark_20ms.fits',/silent)
     im=double(im)
     go_mean_half_median,im,dark20ms
     im=readfits('/media/LaCie/ASTRO/ANDOR/JD2455719/2455719.8715391DARK_Dark_60s.fits',/silent)
     im=double(im)
     go_mean_half_median,im,dark60s
     ;
     writefits,'halfmeanmedian60sdark.fits',dark60s
     print,'MEan of corner of saved dark file: ',mean(dark60s(0:50,0:50))
     writefits,'halfmeanmedian20msdark.fits',dark20ms
     print,'MEan of corner of saved dark file: ',mean(dark20ms(0:50,0:50))
     endif
 if (ifbuild_darks ne 1) then begin
     print,'So, reading darks ...'
     dark60s=readfits('halfmeanmedian60sdark.fits',/silent)
     dark20ms=readfits('halfmeanmedian20msdark.fits',/silent)
     endif
 ; get all images and read their exposure time, subtract the best dark frame, write
 ; KEDF35
 print,'So, building KEDF35 ...'
 files=file_search(path+'*KEDF35*',count=n)
 for i=0,n-1,1 do begin
     im=readfits(files(i),header,/silent)
     im=double(im)
     get_EXPOSURE,header,exptime
     l=size(im)
     buildname,files(i),basicname
     print,'EXPOSURE: ',exptime,' l: ',l(0),' mean of corner: ',mean(im(0:50,0:50))
     if (l(0) eq 2) then begin
         ; single image
         im=(im-dark60s)/60.0
         fitsnameout=strcompress('PROCESSED/'+basicname+'_DFremoved'+'.fits',/remove_all)
         writefits,fitsnameout,im,header
         print,'MEan of corner of saved file: ',mean(im(0:50,0:50))
         endif
     if (l(0) eq 3) then begin
         stop
         ; image stack
         endif
     endfor
 ; IRCUT
 print,'So, building IRCUT...'
 files=file_search(path+'*IRCUT.*',count=n)
 for i=0,n-1,1 do begin
     im=readfits(files(i),header,/silent)
     im=double(im)
     get_EXPOSURE,header,exptime
     l=size(im)
     buildname,files(i),basicname
     print,'EXPOSURE: ',exptime,' l: ',l(0),' mean of corner: ',mean(im(0:50,0:50))
     if (l(0) eq 2) then begin
         ; single image
         im=im-dark60s
         im=im/60.0
         fitsnameout=strcompress('PROCESSED/'+basicname+'_DFremoved'+'.fits',/remove_all)
         writefits,fitsnameout,im,header
         print,'MEan of corner of saved file: ',mean(im(0:50,0:50))
         endif
     if (l(0) eq 3) then begin
         stop
         ; image stack
         endif
     endfor
 ; IRCUT_2
 print,'So, building IRCUT_2...'
 files=file_search(path+'*IRCUT_2*',count=n)
 for i=0,n-1,1 do begin
     im=readfits(files(i),header,/silent)
     im=double(im)
     get_EXPOSURE,header,exptime
     l=size(im)
     buildname,files(i),basicname
     print,'EXPOSURE: ',exptime,' l: ',l(0),' mean of corner: ',mean(im(0:50,0:50))
     if (l(0) eq 2) then begin
         ; single image
         im=im-dark60s
         im=im/60.0
         fitsnameout=strcompress('PROCESSED/'+basicname+'_DFremoved'+'.fits',/remove_all)
         writefits,fitsnameout,im,header
         print,'MEan of corner of saved file: ',mean(im(0:50,0:50))
         endif
     if (l(0) eq 3) then begin
         stop
         ; image stack
         endif
     endfor
 ; BBSO_AIR
 print,'So, building BBSO_AIR...'
 files=file_search(path+'*BBSO_AIR*',count=n)
 for i=0,n-1,1 do begin
     im=readfits(files(i),header,/silent)
     im=double(im)
     get_EXPOSURE,header,exptime
     l=size(im)
     buildname,files(i),basicname
     print,'EXPOSURE: ',exptime,' l: ',l(0),' mean of corner: ',mean(im(0:50,0:50))
     if (l(0) eq 2) then begin
         ; single image
         im=im-dark20ms
         im=im/0.02
         fitsnameout=strcompress('PROCESSED/'+basicname+'_DFremoved'+'.fits',/remove_all)
         writefits,fitsnameout,im,header
         print,'MEan of corner of saved file: ',mean(im(0:50,0:50))
         endif
     if (l(0) eq 3) then begin
         stop
         ; image stack
         endif
     endfor
 ; CoAdd
 print,'So, building CoAdd...'
 files=file_search(path+'*CoAdd*',count=n)
 for i=0,n-1,1 do begin
     im=readfits(files(i),header,/silent)
     im=double(im)
     get_EXPOSURE,header,exptime
     l=size(im)
     buildname,files(i),basicname
     print,'EXPOSURE: ',exptime,' l: ',l(0),' mean of corner: ',mean(im(0:50,0:50))
     if (l(0) eq 2) then begin
         ; single image
         im=im-dark20ms
         im=im/0.02
         fitsnameout=strcompress('PROCESSED/'+basicname+'_DFremoved'+'.fits',/remove_all)
         writefits,fitsnameout,im,header,header
         print,'MEan of corner of saved file: ',mean(im(0:50,0:50))
         endif
     if (l(0) eq 3) then begin
         ; image stack
         for j=0,l(3)-1,1 do begin
             im(*,*,j)=(im(*,*,j)-dark20ms)/0.02
             fitsnameout=strcompress('PROCESSED/'+basicname+'_DFremoved'+'.fits',/remove_all)
             endfor
         writefits,fitsnameout,im,header
         go_mean_half_median,im,imout
         fitsnameout=strcompress('PROCESSED/'+basicname+'_DFremoved_coadded'+'.fits',/remove_all)
         writefits,fitsnameout,imout,header
         print,'MEan of corner of saved file: ',mean(im(0:50,0:50))
         endif
     endfor
 end

