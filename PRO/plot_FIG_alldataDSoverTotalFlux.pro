PRO getit,strin,filterstr,data
file='./FORHANS2/WithErrors.MkIIIonelafa.Hapke63_counts_in_features_extracted_'+strin+'_CUBES_try1.dat'
str='cat '+file+" | grep "+filterstr+" | awk '{print $6,($10-$29)/$18,($11-$29)/$18,$19/$27,$20/$27}' "
;str='cat '+file+" | awk '$10 !=0 && $11 !=0 {print $10-$29,$11-$29,$14/($10-$29)*100.,$15/($11-$29)*100.,$29}' "
spawn,str+' > DStotratio.dat'
data=get_data('DStotratio.dat')
ph=reform(data(0,*))
a=reform(data(1,*))
b=reform(data(2,*))
c=reform(data(3,*))
d=reform(data(4,*))
n=n_elements(a)
print,'n=',n
openw,4,strcompress('pDStotratio'+filterstr+strin+'.dat',/remove_all)
for i=0,n-1,1 do begin
if (abs(a(i)) lt abs(b(i))) then begin
	printf,4,ph(i),a(i)
endif else begin
        printf,4,ph(i),b(i)
endelse
endfor
close,4
data=get_data(strcompress('pDStotratio'+filterstr+strin+'.dat',/remove_all))
return
end

!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.CHARSIZE=2.4
!P.CHARTHICK=2
methodnames=['RAW','BBSOlin','BBSOlog','EFM']
filternames=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
for imethod=0,3,1 do begin
!P.MULTI=[0,2,3]
for ifilter=0,4,1 do begin
filterstr=filternames(ifilter)
str=methodnames(imethod)
getit,str,filterstr,data
print,'min,max abs phase: ',min(abs(data(0,*))),max(abs(data(0,*))),' min,max abs ratio: ',min(abs(data(1,*))),max(abs(data(1,*)))
idx=where(data(1,*) gt 0)
plot,xrange=[30,140],yrange=[3e-10,10.0e-8],xstyle=3,ystyle=3,title=str+filterstr,abs(data(0,idx)),data(1,idx),psym=7,/ylog,xtitle='Absolute lunar phase',ytitle='Observed DS/tot'
endfor
endfor
end
