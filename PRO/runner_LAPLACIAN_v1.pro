PRO getOKtousethisfile,filename,ifOK
ifOK=0
; this routine will check the filename againsta  list of 
; kosher filenames and return ifOK=1 if the JD is on that list
print,'Checking if ',filename,' is kosher.'
get_lun,erf
openr,erf,'Chris_list_good_images.txt'
ic=0
while not eof(erf) do begin
str=''
readf,erf,str
if (ic eq 0) then list=str
if (ic gt 0) then list=[list,str]
ic=ic+1
endwhile
close,erf
free_lun,erf
; 
n=n_elements(list)
for i=0,n-1,1 do begin
idx=strpos(filename,list(i))
if (idx(0) ne -1) then ifOK=1
endfor
return
end

FUNCTION SUN_MOON_EARTH_ANGLE,jd
V=(jd-2451550.1)/29.530588853
V=V-fix(V)
if (V lt 0) then  V=V+1
V=V*360.

return,V-180.
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

 PRO getcoordsfromheader,header,x0,y0,radius
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then print,'DISCX0 not in header.'
 x0=float(strmid(header(jdx),15,9))
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then print,'DISCY0 not in header.'
 y0=float(strmid(header(jdx),15,9))
 idx=strpos(header,'DISCRA')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then print,'DISCRA not in header.'
 radius=float(strmid(header(jdx),15,9))
 return
 end

 PRO gogetjulianday,header,jd
 idx=strpos(header,'JULIAN')
 str=header(where(idx ne -1))
 jd=double(strmid(str,15,15))
 return
 end

 PRO get_radius,header,radius
 idx=where(strpos(header, 'RADIUS') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 RADIUS=float(strmid(str,16,15))
 return
 end
 
 PRO  getsignaturesize,im,radius,sig1,sig2
 ; get the size of the Laplacian derivatibves
     w=35
     ic=0
 ww=radius*2./3.
 for irow=256-ww,256+ww,3 do begin
     d=sqrt(radius^2-(irow-256)^2)
     ileft=256-d
     iright=256+d
     lin=im(*,irow)
     bit1=lin(ileft-w:ileft+w)
     bit2=lin(iright-w:iright+w)
     if (ic eq 0) then sum1=bit1
     if (ic eq 0) then sum2=bit2
     if (ic gt 0) then sum1=sum1+bit1
     if (ic gt 0) then sum2=sum2+bit2
     ic=ic+1
 endfor
     sum1=sum1/float(ic-1)
     sum2=sum2/float(ic-1)
sum1=convol(sum1,[-1,2,-1])
sum2=convol(sum2,[-1,2,-1])
	!P.MULTI=[0,1,2]
	plot,sum1-mean(sum1)
	plot,sum2-mean(sum2)
     dummy1=max(sum1)-min(sum1)
     dummy2=max(sum2)-min(sum2)
     sig1=min([dummy1,dummy2])
     sig2=max([dummy1,dummy2])
 return
 end
 
 PRO getIearth,header,Iearth
 ipos=where(strpos(header,'IEARTH') ne -1)
 date_str=strmid(header(ipos),11,21)
 dummy=float(date_str)
 Iearth=dummy(0)
 return
 end
 
 PRO get_mphase,h,phase
 idx=where(strpos(h,'MPHASE') eq 0)
 phase=-911
 if (idx(0) ne -1) then begin
     phase=float(strmid(h(idx),12,30-12))
     endif
 return
 end
 
 
 
 ;--------------------------------------------------------------
 ; Version 1. Applies the 'Laplacian signature' method on observed
 ; images using the 'DS/BS signature' idea.
 ;--------------------------------------------------------------
 filters=['B','V','VE1','VE2','IRCUT']
 lowpath='/media/bf458fbd-da4b-4083-b564-16d3aceb4c3e/'
 for ifilter=0,4,1 do begin
 filter=filters(ifilter)
 str=strcompress(lowpath+'DARKCURRENTREDUCED/SELECTED_1/245*_'+filter+'_*.fits',/remove_all)
 files=file_search(str,count=n)
 print,'Found : ',n,' images.'
 fname=strcompress('ERASEMEWHENYOUSEEME.Laplacian_Results_'+filter+'_.dat',/remove_all)
 openw,3,fname
 bias=readfits('superbias.fits',/SIL)
 for i=0,n-1,1 do begin
     ifOK=0
     getOKtousethisfile,files(i),ifOK 
     im=readfits(files(i),/silent,h)-bias
     totflux=total(im,/double)
     im=im+500.	; for convenience
     print,'Considering ',i,' of ',n
     getcoordsfromheader,h,x00,y00,radius0 & x0=x00(0) & y0=y00(0) & radius=radius0(0)
     im=shift(im,256-x0,256-y0)
     if (ifOK eq 1 and x0 gt radius+50 and x0 lt 511-radius-50 and y0 gt radius+50 and y0 lt 511-radius-50) then begin
     im=smooth(im,3,/edge_truncate)
     get_time,h,JD
         getsignaturesize,im,radius,sig1,sig2
         gostripthename,files(i),imagename
         get_filtername,h,filtername
;        printf,3,format='(1x,f15.7,1x,f7.2,1(1x,e15.7),1x,a,1x,a)',jd,SUN_MOON_EARTH_ANGLE(jd),sig1/sig2,filtername,imagename
;        print,format='(1x,f15.7,1x,f7.2,1(1x,e15.7),1x,a,1x,a)',jd,SUN_MOON_EARTH_ANGLE(jd),sig1/sig2,filtername,imagename
         printf,3,format='(1x,f15.7,1x,f7.2,1(1x,e15.7))',jd,SUN_MOON_EARTH_ANGLE(jd),sig1/sig2
         print,format='(1x,f15.7,1x,f7.2,1(1x,e15.7))',jd,SUN_MOON_EARTH_ANGLE(jd),sig1/sig2
	endif
     endfor
 close,3
 endfor
 print,'The results are now in the file "'+fname+'" - RENAME!'
 end
