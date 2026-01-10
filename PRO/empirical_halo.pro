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

PRO getfiltername,filename,filtername
 ;/media/SAMSUNG/CLEANEDUP2455945/2455945.0716098MOON_VE2_AIR_DCR.fits
 bit1=strmid(filename,strpos(filename,'_')+1,strlen(filename))
 filtername=strmid(bit1,0,strpos(bit1,'_'))
 return
 end

PRO getstats,list,cumulative,limit,number,valueint
 idx=where(cumulative ge limit)
 number=float(n_elements(idx))
 valueint=list(idx(0))
 return
 end
 
 PRO findafittedlinearsurface,im,thesurface
 l=size(im,/dimensions)
 Nx=l(0)
 Ny=l(1)
 XR = indgen(Nx)
 YC = indgen(Ny)
 X = double(XR # (YC*0 + 1))        ;     eqn. 1
 Y = double((XR*0 + 1) # YC)        ;     eqn. 2
 ;----------------------------------------
 thesurface=findgen(512,512)*0.0
 get_lun,wxy
 openw,wxy,'masked.dat'
 for i=0,511,1 do begin
     for j=0,511,1 do begin
         if ((i le 50 or i gt 511-50) and (j le 50 or j ge 511-50)) then begin
             printf,wxy,i,j,im(i,j)
             endif
         endfor
     endfor
 close,wxy
 free_lun,wxy
 data=get_data('masked.dat')
 res=sfit(data,/IRREGULAR,1,kx=coeffs)
 thesurface=coeffs(0,0)+coeffs(1,0)*y+coeffs(0,1)*x+coeffs(1,1)*x*y
 return
 end
 
 PRO showcontours,file,str
 im=readfits(file,header,/silent)
;......................................
     getfiltername,file,filtername
     get_time,header,jd
     mlo_airmass,jd,am
;......................................
 ; get rid of any sky brightness
 findafittedlinearsurface,im,thesurface
 im=im-thesurface
 ; sort all pixels in terms of brightness
 list=im((sort(im)))
 n=n_elements(list)
 ; sum all the pixel brightnesses in order
 cumulative=total(list,/cumul)
 ; get the contribution as fraction of total brightness
 cumulative=cumulative/total(im,/double)
 ; find the levels corresponding to various fractiles
 levellist=[0.001,0.002,0.1]
 openw,63,'cumul_stats.dat'
 for jj=0,n_elements(levellist)-1,1 do begin
     getstats,list,cumulative,levellist(jj),number,valueint
     if (jj eq 0) then levs=valueint
     if (jj gt 0) then levs=[levs,valueint]
     printf,63,levellist(jj),number,valueint
 endfor
     close,63
 for ilevels=0,n_elements(levs)-1,1 do begin
     if (ilevels eq 0) then contour,im,levels=levs(ilevels),/isotropic,c_linestyle=ilevels,xstyle=3,ystyle=3,title=str+' 0.1, 0.5 and 10% contours'
     if (ilevels gt 0) then contour,im,levels=levs(ilevels),/overplot,c_linestyle=ilevels
 endfor	
     ; get the stats for inter-fractile range
     data=get_data('cumul_stats.dat')
     level=reform(data(0,*))
     area=reform(data(1,*))
     intensity=reform(data(2,*))
print,format='(f18.7,1x,i9,1x,f9.4,1x,a)',jd,area(1)-area(2),am,filtername
printf,44,format='(f18.7,1x,i9,1x,f9.4)',jd,area(1)-area(2),am
 return
 end
 
 
 filters=['B','V','VE1','VE2','IRCUT']
 night='2456004'
 night='2456005'
 print,'------------------------------------------------'
 for ifilter=0,n_elements(filters)-1,1 do begin
 !P.MULTI=[0,3,4]
 filtername=filters(ifilter)
 print,'FILTER: ',filtername
 lowpath='/data/pth/DATA/ANDOR/'
 files=file_search(lowpath+'DARKCURRENTREDUCED/JD'+night+'/*_'+filtername+'_*',count=n)
 openw,44,'fractile_list.dat'
 for i=0,n-1,1 do begin
     file=files(i)
     showcontours,file,filtername
     endfor
 close,44
 data=get_data('fractile_list.dat')
 jd=reform(data(0,*))
 nfractile=n_elements(jd)
 area=reform(data(1,*))
 am=reform(data(2,*))
 !p.charsize=2
 !P.THICK=2
 !x.THICK=2
 !y.THICK=2
 !P.MULTI=[0,2,4]
 plot,title=filtername,psym=7,ystyle=3,xstyle=3,jd-long(jd),area,xtitle='fractional day',ytitle='fractile area'
 plot,title=filtername,psym=7,ystyle=3,xstyle=3,area,am,xtitle='fractile area',ytitle='Airmass'
 fname=strcompress('_'+filtername+'_',/remove_all)
 str="grep "+fname+" results_FFM_onrealimages_"+night+".dat | awk '{print $1,$2,$11,$15}' > aha.dat"
 print,str
 spawn,str
 data=get_data('aha.dat')
 jd2=reform(data(0,*))
 naha=n_elements(jd2)
 alfa=reform(data(1,*))
 am2=reform(data(2,*))
 albedo=reform(data(3,*))
 plot,title='FFM '+filtername,psym=7,ystyle=3,xstyle=3,albedo,am2,xtitle='albedo',ytitle='Airmass'
 if (naha eq nfractile) then begin
 plot,title='FFM '+filtername,psym=7,ystyle=3,xstyle=3,jd2-long(jd2),alfa,xtitle='fractional day',ytitle='!7a!3'
 plot,title='FFM '+filtername,psym=7,ystyle=3,xstyle=3,albedo,alfa,xtitle='albedo',ytitle='!7a!3'
 plot,title='FFM '+filtername,psym=7,ystyle=3,xstyle=3,area,alfa,xtitle='fractile area',ytitle='!7a!3'
 plot,title='FFM '+filtername,psym=7,ystyle=3,xstyle=3,am2,alfa,xtitle='airmass',ytitle='!7a!3'
 res=linfit(am2,alfa,/double,yfit=yhat,sigma=sigs)
 oplot,am2,yhat
 print,' LINFIT res:',res
 print,' sigma:',sigs
 print,' Estimate of alfa_0 : ',res(0),' +/- ',sigs(0)
 res=ladfit(am2,alfa,/double)
 print,' LADFIT res:',res
 print,' Estimate of alfa_0 : ',res(0)
 print,'------------------------------------------------'
 endif
 
stop
 endfor
 end
