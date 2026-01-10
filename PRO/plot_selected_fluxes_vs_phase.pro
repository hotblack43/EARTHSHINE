PRO gointerpolate,x,y,str
print,'....................................'
print,'   Phase  flux for filter '+str
for ph=40,90,1 do begin
out=interpol(y,x,ph)
print,ph,out
endfor
openw,55,strcompress('Fluxtables_Moon'+str+'.dat',/remove_all)
printf,55,'   Phase             flux for filter '+str
for ph=40,90,1 do begin
out=interpol(y,x,ph)
printf,55,ph,out
endfor
close,55
return
end

; plot the lot
 !P.CHARSIZE=2
 filters=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
 ExtCoe=[0.2,0.14,0.1,0.05,0.1]
 !P.MULTI=[0,1,1]
 !P.THICK=2
 !P.CHARTHICK=2
 !x.THICK=2
 !y.THICK=2
 ;!P.MULTI=[0,2,3]
 mecol=['blue','green','orange','red','orange']
 ; concatenate all files
 openr,1,'GOODRESULTS/theeeGoodList.txt'
 ic=0
 while not eof(1) do begin
 yesno=0
 name=''
 readf,1,yesno,name
 if (yesno eq 1) then begin
        nname=strcompress('GOODRESULTS/'+name,/remove_all)
	if (ic eq 0) then spawn,'cat '+nname+' > GOODRESULTS/alldata'
	if (ic gt 0) then spawn,'cat '+nname+' >> GOODRESULTS/alldata'
        ic=ic+1
 endif
 endwhile
 close,1
 for ifilter=0,4,1 do begin
 str='grep '+filters(ifilter)+" GOODRESULTS/alldata | awk '{print $4,$1,$2}' > plotme"
 spawn,str
 data=get_data('plotme')
 ph=reform(data(0,*))
 flx=reform(data(1,*))
 am=reform(data(2,*))
 jdx=where(am lt 4)
 data=data(*,jdx)
 ph=reform(data(0,*))
 flx=reform(data(1,*))
 am=reform(data(2,*))
 corrFlx=10^(-(-2.5*alog10(flx)-ExtCoe(ifilter)*am)/2.5)
 if (ifilter eq 0) then plot_io,xrange=[20,90],yrange=[1e8,1e11],psym=1,ph,corrFlx,title='am < 4; B,V,VE1,VE2,IRCUT',xtitle='Lunar phase',ytitle='Total flux, ext. corr.'
 oplot,ph,corrFlx,psym=1,color=fsc_color(mecol(ifilter))
 ; plot a robust poly on top
 jdx=where(ph lt 94)
 x=ph(jdx)
 y=corrFlx(jdx)
 klx=sort(x)
 x=x(klx)
 y=y(klx)
 COEFF = ROBUST_POLY_FIT(x,y,4,yfit)
 oplot,x,yfit,color=fsc_color(mecol(ifilter))
 gointerpolate,x,yfit,filters(ifilter)
 endfor
 ; clean up
; spawn,'rm GOODRESULTS/alldata'
 end
