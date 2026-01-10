PRO coaddslicesIntelligently,im
l=size(im)
if (l(0) lt 3) then return
im=avg(im,2,/double)
return
end

PRO gofilterthefilenames,files,list,n
nwords=n_elements(list)
n=n_elements(files)
for iword=0,nwords-1,1 do begin
help,files
print,'getting rid of files with ',list(iword),' in them.'
z=strpos(files,list(iword))
idx=where(z eq -1)
files=files(idx)
n=n_elements(files)
endfor
return
end

PRO gofindALLstarfields,path,starname,listofDARKnames,listofDARK_JDtimes
 name=strcompress(path+'*'+starname+'*',/remove_all)
 files=file_search(path,'*MOON*.fit*',count=n)
 gofilterthefilenames,files,['TAURI','DITHER','BAD','averaged'],n
 print,'Found ',n,' stars.'
 ic=0
 openw,44,'STARS.dat'
 for i=0L,n-1,1 do begin
	print,'In gofindALLstarfields, dealing with file: ',files(i)
     im=readfits(files(i),/sil,header)
     get_info_from_header,header,'UNSTTEMP',temp
     get_info_from_header,header,'EXPOSURE',texp
     get_info_from_header,header,'FRAME',JD
     flag_temp=1
     if (temp ne -999) then flag_temp=0
     flag_exposure=0
     if (max(im) gt 10000 and max(im) le 55000) then flag_exposure=1
     if (flag_temp*flag_exposure ne 1) then print,'CANNOT use this frame: ',temp,max(im),files(i)
     if (flag_temp*flag_exposure eq 1) then begin
         print,'This one is OK T: ',temp,'max(counts):',max(im),' ',files(i)
         if (ic eq 0) then listofDARKnames=files(i)
         if (ic eq 0) then listofDARK_JDtimes=JD
         if (ic gt 0) then listofDARKnames=[listofDARKnames,files(i)]
         if (ic gt 0) then listofDARK_JDtimes=[listofDARK_JDtimes,JD]
         printf,format='(f15.7,1x,f10.3,1x,f9.4,1x,f10.4)',44,JD,temp,texp,max(im)
         ic=ic+1
         endif
     endfor
 close,44
 return
 end
 
 PRO gofindALLdarkfields,path,listofDARKnames,listofDARK_JDtimes
 print,' In gofindALLdarkfi path=',path
 files=file_search(path,'*DARK*.fit*',count=n)
 gofilterthefilenames,files,['BAD','median'],n
 print,'Found ',n,' files of DARK kind.'
 ic=0
 openw,44,'DARKS.dat'
 for i=0,n-1,1 do begin
print,files(i)
     im=readfits(files(i),/sil,header)
     get_info_from_header,header,'UNSTTEMP',temp
     get_info_from_header,header,'EXPOSURE',texp
     get_info_from_header,header,'FRAME',JD
     if (temp ne -999) then print,i,' Skipping DARK frame due to high temperature= ',temp
     if (temp eq -999) then begin
         print,'T: ',temp
         if (ic eq 0) then listofDARKnames=files(i)
         if (ic eq 0) then listofDARK_JDtimes=JD
         if (ic gt 0) then listofDARKnames=[listofDARKnames,files(i)]
         if (ic gt 0) then listofDARK_JDtimes=[listofDARK_JDtimes,JD]
         printf,format='(f15.7,1x,f10.3,1x,f9.4,1x,f10.4)',44,JD,temp,texp,mean(im,/double)
         ic=ic+1
         endif
     endfor
 close,44
 return
 end
 
 PRO go_add_to_the_right_one,im,exp_time2
 common ims,summdimages,counts,exptimes
 idx=where(exptimes eq exp_time2)
 if (idx(0) eq -1) then begin
     print,'I am unprepared for ',exp_time2,', stopping.'
     stop
     endif
 if (counts(idx(0)) eq 0) then begin
     summdimages(*,*,idx(0))=im
     counts(idx(0))=1
     return
     endif
 if (counts(idx(0)) gt 0) then begin
     summdimages(*,*,idx(0))=summdimages(*,*,idx(0))+im
     counts(idx(0))=counts(idx(0))+1
     return
     endif
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
 if (str eq 'EXPOSURE') then begin
     get_EXPOSURE,header,valout
     return
     endif
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
 if (idx(0) ne -1) then str=header(idx(0))
 measuredtexp=float(strmid(str,24,8))
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

 PRO goplotDARKSdat,str
 data=get_data('DARKS.dat')
 mv=reform(data(3,*))
 expT=reform(data(2,*))
 JD=reform(data(0,*))
 !P.CHARSIZE=2
 !P.THICK=2
 !X.THICK=2
 !Y.THICK=2
 set_plot,'ps'
 device,filename='DC_vs_time.ps'
 plot_oi,psym=7,JD-long(jd(0)),mv,xstyle=3,ystyle=3,xtitle='Fr. day',ytitle='DARK field mean value [ADU]',title=str
 device,/close
 set_plot,'X'
 set_plot,'ps'
 device,filename='DARKCURRENT.ps'
 plot_oi,psym=7,expT,mv,xrange=[0.001,max(expT)],xstyle=3,ystyle=3,xtitle='Exposure time [s]',ytitle='DARK field mean value [ADU]',title=str
 device,/close
 set_plot,'X'
 return
 end
 
 
 ;...........................................................................
 ; Pipeline that processes all images in a directory and finds the
 ; DARK frames surrounding groups of science frames and uses a scaled version
 ; of the superbias to subtract bias and dark current.
 ;...........................................................................
 ; Version 3 : Does ALL files under the path 'path'
 ;...........................................................................
 common ims,summdimages,counts,exptimes
 ; clear all the previously reduced data
 spawn,'rm -r DARKCURRENTREDUCED/'
 spawn,'mkdir DARKCURRENTREDUCED'
 spawn,'mkdir JPEG'
 print,'Old output data cleared'
 ; set the path to the data
 path='/media/SAMSUNG/MOONDROPBOX/'
 bias=readfits('../TTAURI/superbias.fits',/SIL)
 starname='MOON'
 ; find the MOON frames
 gofindALLstarfields,path,starname,listofSTARnames,listofSTAR_JDtimes
 ; wind the DARK frames
 gofindALLdarkfields,path,listofDARKnames,listofDARK_JDtimes & goplotDARKSdat,NIGHT
 ; set up OUTPUT names
 names=strarr(n_elements(listofSTARnames))
 names_jpeg=strarr(n_elements(listofSTARnames))
 for k=0,n_elements(listofSTARnames)-1,1 do begin
     bit1=strmid(LISTOFSTARNAMES(k),0,strpos(LISTOFSTARNAMES(k),'.fits'))+'_DCR.fits'
     bit2=strmid(bit1,strpos(bit1,'/245')+1,strlen(bit1))
     names(k)=strcompress('DARKCURRENTREDUCED/'+bit2,/remove_all)
     names_jpeg(k)=strcompress('JPEG/'+bit2,/remove_all)
     print,'a name:',names(k)
     endfor
 ; loop over all stars and remove average dark frame
 for istar=0,n_elements(names)-1,1 do begin
     im=readfits(listofSTARnames(istar),/sil,h)
print,'grappling with: ',listofSTARnames(istar),istar,' of ',n_elements(names)
	coaddslicesIntelligently,im
     ijd=listofSTAR_JDtimes(istar)
     delta_dark=listofDARK_JDtimes-ijd
     JDbefore=max(listofDARK_JDtimes(where(delta_dark eq max(delta_dark(where(delta_dark lt 0))))))
     JDafter=min(listofDARK_JDtimes(where(delta_dark eq min(delta_dark(where(delta_dark gt 0))))))
     idx_1=where(listofDARK_JDtimes eq JDbefore)
     idx_2=where(listofDARK_JDtimes eq JDafter)
	if (n_elements(idx_1) gt 1) then idx_1=idx_1(0)
	if (n_elements(idx_2) gt 1) then idx_2=idx_2(0)
     print,idx_1,idx_2
     print,'MOON file used:',listofSTARnames(istar)
     print,'Two DARK frames used:',listofDARKnames(idx_1),listofDARKnames(idx_2)
     bestDCim=(readfits(listofDARKnames(idx_1),/SIL)+readfits(listofDARKnames(idx_2),/SIL))/2.0d0
     ; scale the superbias to match the mean of bestDCim - thus avoiding adding noise
     bestscaledsuperbias=bias/mean(bias,/double)*mean(bestDCim,/double)
     out=im-bestscaledsuperbias
	writefits,'bestDC.fits',bestscaledsuperbias
     writefits,names(istar),out,h
	jpegname=strcompress(names_jpeg(istar),/remove_all)
	jpegname=strmid(jpegname,0,strlen(jpegname)-1-4)+'.gif'
     write_gif,strcompress(jpegname,/remove_all),bytscl(out)
;stop
     endfor
 end
