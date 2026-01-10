@stuf33.pro
 PRO gogetjulianday,header,jd
 idx=strpos(header,'JULIAN')
 str=header(where(idx ne -1))
 jd=double(strmid(str,15,15))
 return
 end

 PRO get_mask,x0,y0,radius,mask
 ; build a 1/0 mask that is a circle (center x0,y0) and radius r with 0's outside radius and 1's inside
 common sizes,l
 nx=l(0) & ny=l(1) & mask=fltarr(nx,ny)
 for i=0,nx-1,1 do begin
     for j=0,ny-1,1 do begin
         rad=sqrt((i-x0)^2+(j-y0)^2)
         if (rad ge radius) then mask (i,j)=0 else mask(i,j)=1.0
         endfor
     endfor
 return
 end

 PRO gostripthename,str,fitsname
 ;xx=strpos(str,'245')
 ;fitsname=strmid(str,xx,strlen(str)-xx)
 str2=strsplit(str,'/',/extract)
 fitsname=str2(n_elements(str2)-1)
 return
 end
 
 PRO get_filtername,header,name
 ;
 idx=where(strpos(header, 'DMI_COLOR_FILTER') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 name=strmid(str,29,8)
 return
 end
 
 PRO read_header,header,JD,exptime
 string=header(where (strpos(header,'EXPTIME') eq 0))
 exptime=float(strmid(string,9,strlen(string)-9))
 string=header(where (strpos(header,'DATE-OBS') eq 0))
 yy=fix(strmid(string,11,4))
 mm=fix(strmid(string,16,2))
 dd=fix(strmid(string,19,2))
 string=header(where (strpos(header,'TIME-OBS') eq 0))
 hh=fix(strmid(string,11,2))
 mi=fix(strmid(string,14,2))
 ss=float(strmid(string,17,6))
 JD=double(julday(mm,dd,yy,hh,mi,ss))
 return
 end
 
 PRO get_info_from_header,header,str,valout
 if (str eq 'ACT') then begin
     get_cycletime,header,valout
     return
     endif
 if (str eq 'UNSTTEMP') then begin
     get_temperature,header,valout
     return
     endif
 if (str eq 'DMI_ACT_EXP') then begin
     get_measuredexptime,header,valout
     return
     endif
 if (str eq 'DMI_COLOR_FILTER') then begin
     get_filtername,header,valout
     return
     endif
 if (str eq 'FRAME') then begin
     get_time,header,valout
     return
     endif
 return
 end
 
 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 PRO get_cycletime,header,acttime
 idx=where(strpos(header, 'ACT') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 acttime=float(strmid(str,16,15))
 return
 end
 
 PRO get_temperature,header,temperature
 idx=where(strpos(header, 'UNSTTEMP') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 temperature=float(strmid(str,16,15))
 return
 end
 
 PRO get_measuredexptime,header,measuredtexp
 idx=where(strpos(header, 'DMI_ACT_EXP') ne -1)
 str='999'
 measuredtexp=911
 if (idx(0) ne -1) then begin
     str=header(idx(0))
     bit=strmid(str,24,8)
     measuredtexp=999
     if (strmid(bit,0,3) ne 'Not') then measuredtexp=float(strmid(str,24,8))
     endif
 return
 end
 
 PRO get_times,h,act,exptime
 get_info_from_header,h,'DMI_ACT_EXP',act
 get_EXPOSURE,h,exptime
 end
 
 PRO getbasicfilename,namein,basicfilename
 print,namein
 basicfilename=strmid(namein,strpos(namein,'.')-7)
 ;basicfilename=strmid(namein,strpos(namein,'2455'))
 return
 end
 
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
 PRO findafittedlinearsurface,im,mask,thesurface
 l=size(im,/dimensions)
 common xsandYs,X,Y
 ;----------------------------------------
 offset=mean(im(0:10,0:10))
 thesurface=findgen(512,512)*0.0
 mim=im
 get_lun,wxy
 openw,wxy,'masked.dat'
 for i=0,511,1 do begin
     for j=0,511,1 do begin
         ;if (mim(i,j) ne 0.0) then begin
         if ((i le 10 or i gt 500) and (j le 10 or j ge 500)) then begin
             printf,wxy,i,j,mim(i,j)
             ;print,i,j,mim(i,j)
             endif
         endfor
     endfor
 close,wxy
 free_lun,wxy
 data=get_data('masked.dat')
 res=sfit(data,/IRREGULAR,1,kx=coeffs)
 thesurface=coeffs(0,0)+coeffs(1,0)*y+coeffs(0,1)*x+coeffs(1,1)*x*y
 ;thesurface=thesurface+offset
 return
 end
 
 PRO bestBSspotfinder,im,cg_x,cg_y
 ; find the coordinates of a spot near the brightest part of the BS
 l=size(im,/dimensions)
 smooim=median(im,5)
 idx=where(smooim eq max(smooim))
 coo=array_indices(smooim,idx)
 cg_x=coo(0)
 cg_y=coo(1)
 if (cg_x lt 0 or cg_x gt l(0) or cg_y lt 0 or cg_y gt l(1)) then stop
 return
 end
 
 PRO gofindDSandBSinboxes,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS,iflag
 ; determine if BS is to the right or the left of the center
 ; iflag = 1 means position 1
 ; iflag = 2 means position 2
 if (iflag eq 1) then ipos=4./5.
 if (iflag eq 2) then ipos=2./3.
 if (cg_x gt x0) then begin
     ; BS is to the right
     BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
     DS=median(im(x0-radius*ipos-w:x0-radius*ipos+w,y0-w:y0+w))
     endif
 if (cg_x lt x0) then begin
     ; BS is to the left
     BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
     DS=median(im(x0+radius*ipos-w:x0+radius*ipos+w,y0-w:y0+w))
     endif
 return
 end
 
 PRO gogeteverythingelse,im1_in,im2_in,BS,TOT,DS23,DS45
 common circle,cg_x,cg_y,x0,y0,radius
 im1=im1_in
 im2=im2_in
 if_removelinear=1
 if (if_removelinear eq 1) then begin
     get_mask,x0,y0,radius,mask
     findafittedlinearsurface,im1,mask,thesurface
     im1=im1-thesurface
     findafittedlinearsurface,im2,mask,thesurface
     im2=im2-thesurface
     endif
 ;
 w=11
 iflag=2
 gofindDSandBSinboxes,im1,im2,x0,y0,radius,cg_x,cg_y,w,BS,DS23,iflag
 iflag=1
 gofindDSandBSinboxes,im1,im2,x0,y0,radius,cg_x,cg_y,w,BS,DS45,iflag
 TOT=total(im1,/double)
 return
 end
 
 PRO getbasicinfo,filename,jd,filtername,exptime,am
 common ims,im
 im=readfits(filename,header,/silent)
 get_info_from_header,header,'FRAME',JD
 get_filtername,header,filtername
 filtername=strcompress('_'+filtername+'_',/remove_all)
 get_times,header,act,exptime
 mlo_airmass,jd,am
 return
 end
 
 
 ;-------------------------------------------------------------------------------------
 ; Finds synethtic images and extracts DS, BS and total flux
 ; Version 1
 ;-------------------------------------------------------------------------------------
 common ims,im
 common circle,cg_x,cg_y,x0,y0,radius
 common sizes,l
 common xsandYs,X,Y
 ;---------------------------------------------------------------------------------
 get_lun,ww
 openw,ww,'extracted_data_ideal.dat'
 lowpath='OUTPUT/'
 path=strcompress(lowpath+'/',/remove_all)
 files=file_search(path+'LunarImg_00*.fit*',count=nBR)
 print,'Found ',nBR,' ideal files'
 for i=0,nBR-1,1 do begin
     observed=readfits(files(i),header)
	gogetjulianday,header,jd
print,jd
     l=size(observed,/dimensions)
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
     ;find c.g. of the image
     bestBSspotfinder,observed,cg_x,cg_y
     ; find radius and center
	x0=512/2
	y0=512/2
	radius=139
;    gofindradiusandcenter,observed,x0,y0,radius
     radius=radius+16
     ;===============================================
     gogeteverythingelse,observed,observed,BS,TOT,DS23,DS45
     print,format='(f18.7,1x,f20.5,1x,f20.5,3(1x,g12.5))',jd,BS,TOT,DS23,DS45,DS45/TOT
     printf,ww,format='(f18.7,1x,f20.5,1x,f20.5,3(1x,g12.5))',jd,BS,TOT,DS23,DS45,DS45/TOT
     ;===============================================
     endfor
 close,ww
 free_lun,ww
 end
