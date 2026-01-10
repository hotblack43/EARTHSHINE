PRO getfiltername,str,filtername,filternumber,JD
 bits=strsplit(str,'/',/extract)
 idx=where(strpos(strsplit(str,'/',/extract),'24') eq 0)
 filename=bits(idx)
 JD=double(filename)
 bits=strsplit(filename,'_',/extract)
 filtername=bits(1)
 if (filtername eq 'B') then filternumber='1'
 if (filtername eq 'V') then filternumber='2'
 if (filtername eq 'VE1') then filternumber='3'
 if (filtername eq 'VE2') then filternumber='4'
 if (filtername eq 'IRCUT') then filternumber='5'
 return
 end
 
 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 ChrisGoodList='Chris_list_good_images.txt'
 path='./DARKCURRENTREDUCED/SELECTED_1/'
 openw,2,'inventory_properties.dat'
 openr,1,ChrisGoodList
 while not eof(1) do begin
print,'---------------------------------------------------------'
     !P.MULTI=[0,2,3]
     file=''
     readf,1,file
     str=path+'*'+file+'*.fits*'
     print,str
     filesFound=file_search(str,count=n)
     if (n eq 1) then begin
         im=readfits(filesFound(0),header,/silent)
         getfiltername,filesFound(0),filtername,filternumber,JD
         if (max(im) gt 10000 and max(im) lt 55000) then begin
             print,format='(f15.7,1x,a)',jd,filesFound(0)
             gofindradiusandcenter,im,x0,y0,radius
             MOONPHASE,jd,phase_angle_M
             mphase,jd,k
             get_EXPOSURE,header,exptime
             imshifts=[256-x0,256-y0]
             im=shift(im,imshifts(0),imshifts(1))
             contour,hist_equal(im),/cell_fill,/isotropic,xstyle=3,ystyle=3
             plot,im(*,256),/ylog,xstyle=3,yrange=[0.01,50000],ystyle=3
             oplot,[256-radius,256-radius],[0.1,1000],linestyle=2
             oplot,[256+radius,256+radius],[0.1,1000],linestyle=2
             ; get the ratio of halo at 20 beyond edge to maxflux
             q20=im(256+radius+20,256)/max(im)
             q21=mean(im(0:10,0:10))
             fmtstr='(f15.7,8(1x,f10.5),1x,i2)'
             print,format=fmtstr,JD,x0,y0,radius,k,phase_angle_M,exptime,q20,q21,filternumber
             printf,2,format=fmtstr,JD,x0,y0,radius,k,phase_angle_M,exptime,q20,q21,filternumber
             endif
         endif else begin
         print,'n was not 1: ',n
         print,str
         endelse
     endwhile
 close,1
 close,2
 end
 
