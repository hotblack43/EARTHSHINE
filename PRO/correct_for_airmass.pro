PRO gocorrect_am,juld,totflux,am,filnames,filter
!P.CHARSIZE=1.1
	mags=15.-2.5*alog10(totflux)
openw,48,strcompress('extinctions_'+filter+'.dat',/remove_all)
for iJD=2455814L,2456104L,1 do begin
print,'--------------------------'
print,'looking for ',iJD+0.5d0,' to ',iJD+1.5d0
jdx=where(am le 4 and juld ge iJD+0.5d0 and juld lt iJD+1.5d0)
if (jdx(0) eq -1) then print,'Found none'
if (jdx(0) ne -1 and n_elements(jdx) ge 7) then begin
	print,filnames(jdx)
	plot,yrange=[median(mags(jdx))-0.3,median(mags(jdx))+0.3],xrange=[1,4],xstyle=3,ystyle=3,am(jdx),mags(jdx),psym=7,xtitle='Airmass',ytitle='Magnitude',title=strcompress(string(iJD+0.5d0)+' to '+string(iJD+1.5d0))
	;res=ladfit(am(jdx),mags(jdx),absdev=adev,/double)
	;yfit=res(0)+res(1)*am(jdx)
	xx=am(jdx) & yy=mags(jdx) & zz=xx-mean(xx)   
	if (total(zz-zz(0)) ne 0) then begin
	print,xx-mean(xx)
	res= ROBUST_LINEFIT(xx,yy, YFIT, SIG, COEF_SIG )
	oplot,xx,yfit,color=fsc_color('red')
	print,'k: ',res(1),' +/. ',coef_sig(1)
	xyouts,charsize=1.1,1.2,!y.crange(0)+0.8*(!y.crange(1)-!y.crange(0)),'k= '+string(res(1),format='(f7.4)')
	printf,48,res(1),coef_sig(1),iJD+0.5d0
	endif
endif
endfor
close,48
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
 
 PRO correctsodubleslashes,str
 ; will remove double /'s from the filename
 idx=strpos(str,'//')
 if (idx(0) eq -1) then stop
 str=strmid(str,0,idx)+strmid(str,idx+1)
 str=strcompress(str,/remove_all)
 return
 end
 
 PRO gogidata,file,juld,totflux,am,ratio,filnames
 openr,1,file
 ic=0
 while not eof(1) do begin
     print,ic
     str=''
     x=dblarr(4)
     readf,1,x,str
     ;correctsodubleslashes,str
     if (ic eq 0) then begin
         juld=x(0)
         totflux=x(1)
         am=x(2)
         ratio=x(3)
         filnames=str
         endif
     if (ic gt 0) then begin
         juld=[juld,x(0)]
         totflux=[totflux,x(1)]
         am=[am,x(2)]
         ratio=[ratio,x(3)]
         filnames=[filnames,str]
         endif
     ic=ic+1
     endwhile
 close,1
 return
 end
 
 
 filters=['B','V','VE1','VE2','IRCUT']
 for ifilter=0,4,1 do begin
 !P.MULTI=[0,3,4]
     filter=filters(ifilter)
     file=strcompress('ratio_obs_to_model_totflux_'+filter+'.dat',/remove_all)
     gogidata,file,juld,totflux,am,ratio,filnames
     !P.CHARSIZE=1.3
     histo,ratio,0.5,1.5,0.01,title=filter
	idx=where(ratio ge 0.95 and ratio lt 1.05)
     plots,[0.95,0.95],[!Y.crange],linestyle=2
     plots,[1.05,1.05],[!Y.crange],linestyle=2
     gocorrect_am,juld(idx),totflux(idx),am(idx),filnames(idx),filter
     data=get_data(strcompress('extinctions_'+filter+'.dat',/remove_all))
     help,data
     k=reform(data(0,*))
     jdvals=reform(data(1,*))
     histo,k,median(k)-0.35,median(k)+0.35,0.04,title=filter,xtitle='k'
     endfor
 end
