PRO get_sunmoonangle,jd,angle
; returns the angle between Sun and Moon as seen from Earth
angle=1
MOONPOS, jd, ra_moon, dec_moon, dis
eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
; Where is the Sun in the local sky?
        SUNPOS, jd, ra_sun, dec_sun
        eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha,  OBSNAME=obsname
; what is the angular distance between Moon and SUn?
u=0     ; radians
gcirc,u,ra_moon*!dtor, dec_moon*!dtor,ra_sun*!dtor, dec_sun*!dtor,dis
angle=dis/!pi*180.
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

 PRO goprocess,filename,coordname,ds,dserr,bs,filtername,jd
 im=readfits(filename,/silent,header)
 get_info_from_header,header,'FRAME',JD
 get_info_from_header,header,'DMI_COLOR_FILTER',filtername
 arr=get_data(coordname)
 x0=arr(0)
 y0=arr(1)
 r=arr(2)
 w=11
 xc=r*3./4.
 yc=0
 xl=x0-xc-w
 xr=x0-xc+w
 yd=y0-yc-w
 yu=y0-yc+w
 subim=im(xl:xr,yd:yu)
 ds=-911
 if ((xl ge 0 and xl le 511) and (yd ge 0 and yd le 511) and (xr ge 0 and xr le 511) and  (yu ge 0 and yu le 511)) then begin
     ds=total(subim)
     ;ds=mean(subim)*n_elements(subim)
     print,xl,xr,yd,yu,n_elements(subim)
     dserr=stddev(subim)*sqrt(n_elements(subim)-1)
     endif
 bs=total(im,/double)
 return
 end
 
 ;..........................................................
 openw,44,'rainbow1.dat'
 if_remove=0
 coords=file_search('FORCRAY/','coord*',count=nc)
 for i=0,nc-1,1 do begin
     if (if_remove eq 1) then begin
         ;wstr='BBSO method applied to log10 images'
         ;files=file_search('FLATTEN/DARKCURRENTREDUCED/BBSO_CLEANED_LOG/','*.fits',count=n)
         wstr='BBSO method applied'
         files=file_search('FLATTEN/DARKCURRENTREDUCED/BBSO_CLEANED/','*.fits',count=n)
         fstr=strsplit(files(i),'/',/extract)
         cstr=strsplit(coords(i),'/',/extract)
         fnamm=fstr(2)
         cname=cstr(1)
         fnamm=fstr(3)
         strput,fnamm,'d',7
         dummy=strsplit(fnamm,'.',/extract)
         fnamm=dummy(0)
         endif
     if (if_remove ne 1) then begin
         wstr='No scattered-light removal'
         files=file_search('FORCRAY/','*.fits',count=n)
         fstr=strsplit(files(i),'/',/extract)
         cstr=strsplit(coords(i),'/',/extract)
         cname=strcompress(cstr(1)+'.fits',/remove_all)
         strput,cname,'.',7
         fnamm=fstr(2)
         print,fstr
         print,cstr
         cname=cstr(1)
         fnamm=fstr(1)
         print,cname
         print,fnamm
         endif
     if (cname ne fnamm) then stop
     if (cname eq fnamm) then begin
         goprocess,files(i),coords(i),ds,dserr,bs,filtername,jd
         get_sunmoonangle,jd,angle
         if (ds gt 0) then print,format='(f15.7,4(1x,f20.10),1x,f7.3,1x,a)',jd,ds,dserr,bs,bs/ds,angle,filtername
         if (ds gt 0) then printf,44,format='(f15.7,4(1x,f20.10),1x,f7.3,1x,a)',jd,ds,dserr,bs,bs/ds,angle,filtername
         endif
     endfor
 close,44
 ; now plot
 FILNAMS=['B','V','VE1','VE2','IRCUT']
 for ifilter=0,n_elements(FILNAMS)-1,1 do begin
     file='rainbow1.dat'
     openr,1,file
     jd=0.0d0
     ds=0.0
     dserr=0.0
     bs=0.0
     ratio=0.0
     angle=0.0
     name=''
     ic=0
     while not eof(1) do begin
         readf,1,jd,ds,dserr,bs,ratio,angle,name
         name=strcompress(name,/remove_all)
         if (name eq filnams(ifilter)) then begin
             if (ic eq 0 and abs(dserr lt ds/2.)) then $
		line=[jd,ds,dserr,bs,ratio,angle]
             if (ic gt 0 and abs(dserr lt ds/2.)) then $
		line=[[line],[jd,ds,dserr,bs,ratio,angle]]
             ic=ic+1
             endif
         endwhile
     close,1
     l=size(line,/dimensions)
     openw,23,strcompress(filnams(ifilter)+'_rainbow.dat',/remove_all)
     for i=0,l(1)-1,1 do begin
         printf,23,format='(f15.7,5(1x,g15.7))',line(*,i)
         endfor
     close,23
     endfor
 ;................
 !P.MULTI=[0,1,1]
 xptr=0	; point to SEM angle
 xptr=5	; point to SEM angle
 iptr=4		; points to BS/DS ratio
 data=get_data('V_rainbow.dat')
 jd0=2455917.0d0
 xtitle='JD fraction on Dec 20 2011'
 if (xptr eq 5) then jd0=0.0
 if (xptr eq 5) then xtitle='SEM angle'
 xx=reform(data(xptr,*)-jd0) & yy=reform(data(iptr,*))
 plot,title=wstr,yrange=[5000,5e4],xtitle=xtitle,ytitle='total/total(DS box)',/nodata,xx,yy
 oplot,xx,yy,color=fsc_color('blue'),psym=7
 res=linfit(xx,yy,/double,sigma=sigs)
 print,'V Slope: ',res(1),abs(res(1)/sigs(1)),res(1)/mean(yy)*100.,' %'
 ;
 data=get_data('VE2_rainbow.dat')
 xx=reform(data(xptr,*)-jd0) & yy=reform(data(iptr,*))
 oplot,xx,yy,color=fsc_color('red'),psym=7
 res=linfit(xx,yy,/double,sigma=sigs)
 print,'VE2 Slope: ',res(1),abs(res(1)/sigs(1)),res(1)/mean(yy)*100.,' %'
 ;
 data=get_data('B_rainbow.dat')
 xx=reform(data(xptr,*)-jd0) & yy=reform(data(iptr,*))
 oplot,xx,yy,color=fsc_color('cyan'),psym=7
 res=linfit(xx,yy,/double,sigma=sigs)
 print,'B Slope: ',res(1),abs(res(1)/sigs(1)),res(1)/mean(yy)*100.,' %'
 ;
 data=get_data('VE1_rainbow.dat')
 xx=reform(data(xptr,*)-jd0) & yy=reform(data(iptr,*))
 oplot,xx,yy,color=fsc_color('orange'),psym=7
 res=linfit(xx,yy,/double,sigma=sigs)
 print,'VE1 Slope: ',res(1),abs(res(1)/sigs(1)),res(1)/mean(yy)*100.,' %'
 ;
 data=get_data('IRCUT_rainbow.dat')
 xx=reform(data(xptr,*)-jd0) & yy=reform(data(iptr,*))
 oplot,xx,yy,color=fsc_color('yellow'),psym=7
 res=linfit(xx,yy,/double,sigma=sigs)
 print,'IRC Slope: ',res(1),abs(res(1)/sigs(1)),res(1)/mean(yy)*100.,' %'
 ;...........
 stop
 !P.MULTI=[0,1,2]
 data=get_data('V_rainbow.dat')
 plot_io,yrange=[100,2e4],xtitle='JD fraction on Dec 20 2011',ytitle='DS and BS',/nodata,data(0,*)-jd0,data(iptr,*)
 oplot,psym=7,data(0,*)-jd0,data(1,*),color=fsc_color('blue')
 ;
 data=get_data('VE2_rainbow.dat')
 oplot,psym=7,data(0,*)-jd0,data(1,*),color=fsc_color('red')
 ;
 data=get_data('B_rainbow.dat')
 oplot,psym=7,data(0,*)-jd0,data(1,*),color=fsc_color('cyan')
 ;
 data=get_data('VE1_rainbow.dat')
 oplot,psym=7,data(0,*)-jd0,data(1,*),color=fsc_color('orange')
 ;
 data=get_data('IRCUT_rainbow.dat')
 oplot,psym=7,data(0,*)-jd0,data(1,*),color=fsc_color('yellow')
 ;...........
 data=get_data('V_rainbow.dat')
 plot_io,yrange=[1e7,2e8],xtitle='JD fraction on Dec 20 2011',ytitle='DS and BS',/nodata,data(0,*)-jd0,data(iptr,*)
 oplot,psym=7,data(0,*)-jd0,data(3,*),color=fsc_color('blue')
 ;
 data=get_data('VE2_rainbow.dat')
 oplot,psym=7,data(0,*)-jd0,data(3,*),color=fsc_color('red')
 ;
 data=get_data('B_rainbow.dat')
 oplot,psym=7,data(0,*)-jd0,data(3,*),color=fsc_color('cyan')
 ;
 data=get_data('VE1_rainbow.dat')
 oplot,psym=7,data(0,*)-jd0,data(3,*),color=fsc_color('orange')
 ;
 data=get_data('IRCUT_rainbow.dat')
 oplot,psym=7,data(0,*)-jd0,data(3,*),color=fsc_color('yellow')
 end
