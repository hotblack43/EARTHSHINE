PRO getit,strin,filterstr,data
file='./FORHANS2/WithErrors.Hapke63_counts_in_features_extracted_'+strin+'_CUBES_try1.dat'
file='./FORHANS2/WithErrors.MkII.Hapke63_counts_in_features_extracted_'+strin+'_CUBES_try1.dat'
file='./FORHANS2/WithErrors.MkIIItwoalfas.Hapke63_counts_in_features_extracted_'+strin+'_CUBES_try1.dat'
file='./FORHANS2/WithErrors.MkIIIonelafa.Hapke63_counts_in_features_extracted_'+strin+'_CUBES_try1.dat'
str='cat '+file+" | grep "+filterstr+" | awk '{print $1,$6,($10-$29)/$18,($11-$29)/$18,$19/$27,$20/$27}' "
spawn,str+' > DStotratio.dat'
data=get_data('DStotratio.dat')
jd=reform(data(0,*))
ph=reform(data(1,*))
a=reform(data(2,*))
b=reform(data(3,*))
c=reform(data(4,*))
d=reform(data(5,*))
n=n_elements(a)
print,'n=',n
openw,4,strcompress('p_'+filterstr+strin+'.dat',/remove_all)
fmt='(f15.7,2(1x,f11.6))'
for i=0,n-1,1 do begin
if (abs(a(i)) lt abs(b(i))) then begin
	printf,4,format=fmt,jd(i),ph(i),a(i)/c(i)*0.31
endif else begin
        printf,4,format=fmt,jd(i),ph(i),b(i)/d(i)*0.31
endelse
endfor
close,4
data=get_data(strcompress('p_'+filterstr+strin+'.dat',/remove_all))
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
print,'min,max abs phase: ',min(abs(data(1,*))),max(abs(data(1,*))),' min,max abs ratio: ',min(abs(data(2,*))),max(abs(data(2,*)))
idx=where(data(2,*) gt 0)
plot,xrange=[30,140],yrange=[0,1],xstyle=3,ystyle=3,title=str+filterstr,abs(data(1,idx)),data(2,idx),psym=7,xtitle='Absolute lunar phase',ytitle='A*'
endfor
endfor
end
