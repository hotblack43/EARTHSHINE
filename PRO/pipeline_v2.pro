PRO	gohistoeq,out
mini=median(out(0:50,0:50))
out = HIST_EQUAL(out, MINV = mini, MAXV = max(out))
return
end

PRO	getJD,gifname,JDstr
JDstr=strmid(gifname,5,15)
end

PRO gofindALLstarfields,path,starname,listofDARKnames,listofDARK_JDtimes
 name=strcompress(path+'*'+starname+'*',/remove_all)
 files=file_search(name,count=n)
 print,'Found ',n,' stars.'
 ic=0
 openw,44,'STARS.dat'
 for i=0,n-1,1 do begin
     im=readfits(files(i),/sil,header)
     get_info_from_header,header,'UNSTTEMP',temp
     texp=0.0 ; get_info_from_header,header,'DMI_ACT_EXP',texp
     get_info_from_header,header,'FRAME',JD
     flag_temp=1
     ;if (temp ne -999) then flag_temp=0
     flag_exposure=0
     if (max(im) le 55000) then flag_exposure=1
     ;if (max(im) gt 7000 and max(im) le 55000) then flag_exposure=1
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
 print,path
 files=file_search(path+'*DARK*',count=n)
 ic=0
 openw,44,'DARKS.dat'
 for i=0,n-1,1 do begin
     im=readfits(files(i),/sil,header)
     get_info_from_header,header,'UNSTTEMP',temp
     texp=0.0 ; get_info_from_header,header,'DMI_ACT_EXP',texp
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
 ; DARK frames surroundinggroupsof science frames and uses a scaled version
 ; of the superbias to subtract bias and dark current.
 ;...........................................................................
 ; Version 2 : Works on gzipped files only. ONLY subtracts bias and DC.
 ; Uses the MEAN of two nearest dark frames to estimate the proper dark frame
 ;...........................................................................
 ; clear all the previously reduced data
 spawn,'rm -r DARKCURRENTREDUCED/*'
 spawn,'mkdir DARKCURRENTREDUCED/*'
 spawn,'rm -r JPEG/'
 spawn,'mkdir JPEG/'
 print,'Old output data cleared'
 ; set the path to the data
 ;path='../ANTENNA/'
 ;path='/media/SAMSUNG/home/pth/TEMPSTORAGE/'
 ;path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455864/'
 ;path='~/Desktop/ASTRO/EARTHSHINE/HALODIR/'
 path='/media/SAMSUNG/MOONDROPBOX/JD2456017/'
 bias=readfits('../TTAURI/superbias.fits',/SIL)
 common ims,summdimages,counts,exptimes
 openw,59,'meanlevel.dat'
 gofindALLdarkfields,path,listofDARKnames,listofDARK_JDtimes 
 ;goplotDARKSdat,NIGHT
; specify a string that appears in the object filenames
 starname='CLUSTER'
 starname='ANTENNA'
 starname='HALO'
 gofindALLstarfields,path,starname,listofSTARnames,listofSTAR_JDtimes
 ; set up OUTPUT names
 names=strarr(n_elements(listofSTARnames))
 names_gif=strarr(n_elements(listofSTARnames))
 names_png=strarr(n_elements(listofSTARnames))
 for k=0,n_elements(listofSTARnames)-1,1 do begin
     bit1=strmid(LISTOFSTARNAMES(k),0,strpos(LISTOFSTARNAMES(k),'.fits'))+'_DCR.fits'
     bit2=strmid(bit1,strpos(bit1,'/245')+1,strlen(bit1))
     names(k)=strcompress('DARKCURRENTREDUCED/'+bit2,/remove_all)
     names_gif(k)=strcompress('JPEG/'+bit2,/remove_all)
     names_png(k)=strcompress('JPEG/'+bit2,/remove_all)
     print,'a name:',names(k)
     endfor
 ; loop over all stars and remove average dark frame
 for istar=0,n_elements(names)-1,1 do begin
     im=readfits(listofSTARnames(istar),/sil,h)
     get_info_from_header,h,'UNSTTEMP',temp
     texp=0.00; get_info_from_header,h,'DMI_ACT_EXP',texp
     get_info_from_header,h,'FRAME',JD
     ijd=listofSTAR_JDtimes(istar)
     delta_dark=listofDARK_JDtimes-ijd
     JDbefore=max(listofDARK_JDtimes(where(delta_dark eq max(delta_dark(where(delta_dark lt 0))))))
     JDafter=min(listofDARK_JDtimes(where(delta_dark eq min(delta_dark(where(delta_dark gt 0))))))
     idx_1=where(listofDARK_JDtimes eq JDbefore)
     idx_2=where(listofDARK_JDtimes eq JDafter)
     print,idx_1,idx_2
     bestDC=(readfits(listofDARKnames(idx_1),/SIL)+readfits(listofDARKnames(idx_2),/SIL))/2.0d0
     ; scale the superbias to match the mean of bestDC - thus avoiding adding noise
     bestDC=bias/mean(bias)*mean(bestDC)
     out=im-bestDC
; write out only selected images
	if (mean(out(*,10)) gt -1 and mean(out(*,10)) lt 5) then begin
	erase
        window,0,xsize=1024,ysize=512
	out2=out
	gohistoeq,out2
        tv,[bytscl(out),bytscl(out2)]
	JDstr='HH:MM:SS'
	gifname=strcompress(names_gif(istar),/remove_all)
	holder=gifname
	gifname=strmid(holder,0,strlen(gifname)-1-4)+'.gif'
	pngname=strmid(holder,0,strlen(gifname)-1-4)+'.png'
	getJD,gifname,JDstr
        xyouts,/normal,0.1,0.1,'DMI/Lund Obs. Earthshine telescope on Mauna Loa, Hawaii. Dec 10 2011 total lunar eclipse.'
        xyouts,/normal,0.1,0.07,strcompress('Thejll/Flynn observers. Exposure time: '+string(texp,format='(f6.3)')+' JD: '+string(JD,format='(f15.6)')),charsize=1.5
	xyouts,/normal,0.1,0.95,'Linear image',charsize=1.5
	xyouts,/normal,0.6,0.95,'Equalized image',charsize=1.5
        if (texp gt 10) then xyouts,/normal,0.4,0.90,'Totality',charsize=2.0
        out2=tvrd()
     writefits,names(istar),out,h
     write_gif,strcompress(gifname,/remove_all),bytscl(out2)
     write_png,strcompress(pngname,/remove_all),bytscl(out2)
;	plot,out(*,10),ystyle=3
	printf,59,mean(out(*,10)),gifname
	endif
stop
     endfor
close,59
 end
