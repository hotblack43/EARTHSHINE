PRO gofindtheoutliers,x_in,y_in
x=x_in
y=y_in
; will look for outliers (suitbaly defined)
n=n_elements(x)
print,'input data:'
for i=0,n-1,1 do begin
	print,i,x(i),y(i)
endfor
; fit robust line
res=ladfit(x,y,/double,absdev=adev)
yfit=res(0)+res(1)*x
residuals=y-yfit
print,'residuals to ladfit:'
for i=0,n-1,1 do begin
	print,i,residuals(i)/adev
endfor
kdx=where(abs(residuals/adev) gt 2)
mdx=where(abs(residuals/adev) le 2)
x_in=x_in(mdx)
y_in=y_in(mdx)
;print,kdx
;set_plot,'x'
;!P.MULTI=[0,1,1]
;plot,x,y,psym=7,xstyle=3,ystyle=3
;oplot,x,yfit
;if (kdx(0) ne -1) then oplot,x(kdx),y(kdx),psym=4,color=fsc_color('red')
;set_plot,'ps'
;stop
return
end

; plot the lot
 !P.CHARSIZE=2
 filters=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
 magoffsets=[0,-1.14,-2.88,-1.48,-2.82]
 !P.MULTI=[0,2,5]
 openw,91,'MOON_extinctions.dat',/append
 ; set up the input file name
 datname='JD2455858_fluxes.dat'
 readfromfiles=1	; for manual or auto use
 openr,65,'JDname.txt' & JD='' &  readf,65,JD & close,65
 if (readfromfiles eq 1) then datname=strcompress(JD+'_fluxes.dat',/remove_all)
 print,'datname: ',datname
 ; first plot all the data - well, dont do it but get the range
 str="grep '_'  "+datname+" | awk '{print $1,$2}'  > getme"
 print,str
 spawn,str
 inf=file_info('getme')
 ;if(inf.size eq 0) then stop
 if(inf.size ne 0) then begin
 aha=get_data('getme')
 flx=reform(aha(0,*))
 am=reform(aha(1,*))
 xra=[min(30.-2.5*alog10(flx)),max(30.-2.5*alog10(flx))]
 ; then plot individual filters
bmag=9999
firstgood=9999
     for i=0,4,1 do begin
         ; set pointer for plots
         x=10-2*i
         !P.MULTI=[x,2,5]
         fname=strcompress(filters(i)+'.dat',/remove_all)
         str='grep '+filters(i)+' '+datname+"  | awk '{print $1,$2}' > "+fname
         spawn,str
         inf2=file_info(fname)
         if(inf2.size ne 0) then begin
             aha=get_data(fname)
             am=reform(aha(1,*))
             idx=where(am le 4 and aha(0,*) gt 0)
             if (n_elements(idx) gt 2) then begin
                 aha=aha(*,idx)
                 flx=30.-2.5*alog10(reform(aha(0,*)))
                 am=reform(aha(1,*))
                 plot,psym=1,ystyle=3,am,flx,title=filters(i)+'   '+datname,xrange=[0.9,6.2],xtitle='airmass',ytitle='Flux [mags]',yrange=xra
                 res=ladfit(am,flx,/double,absdev=adev)
                 yfit=res(0)+res(1)*am
                 oplot,am,yfit,color=fsc_color('red')
;................................................
; outlier removal
;		 print,'before adev: ',adev
;	         if (n_elements(am) ge 3) then gofindtheoutliers,am,flx
;                 res=ladfit(am,flx,/double,absdev=adev)
;		 print,'after adev: ',adev
;                 yfit=res(0)+res(1)*am
;                 oplot,am,yfit,color=fsc_color('green')
;................................................
                 if (n_elements(flx) gt 2) then begin
                     print,'Doing a histo with ',n_elements(flx),' in.'
                     histo,xtitle='30-2.5*log!d10!n Flux',flx,1,11,0.1,title=filters(i)
		     if (i eq 0) then bmag=median(flx)
		     oplot,[bmag+magoffsets(i),bmag+magoffsets(i)],[!y.crange],color=fsc_color('blue')
                     endif
                 print,format='(a10,1x,f9.3)',filters(i),res(1)
                 print,format='(3(1x,f9.3))',adev
                 printf,91,format='(a10,1x,f9.3,1x,a)',filters(i),res(1),jd
                 endif
             endif
         endfor
     endif
 close,91
 end
