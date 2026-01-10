PRO getit,strin,data
file='./FORHANS2/WithErrors.Hapke63_counts_in_features_extracted_'+strin+'_CUBES_try1.dat'
file='./FORHANS2/WithErrors.MkIIIonelafa.Hapke63_counts_in_features_extracted_'+strin+'_CUBES_try1.dat'
file='./FORHANS2/WithErrors.MkIIItwoalfas.Hapke63_counts_in_features_extracted_'+strin+'_CUBES_try1.dat'
file='./FORHANS2/WithErrors.MkII.Hapke63_counts_in_features_extracted_'+strin+'_CUBES_try1.dat'
str='cat '+file+" | awk '$10 !=0 && $11 !=0 {print $10-$29,$11-$29,$14/($10-$29)*100.,$15/($11-$29)*100.,$29}' "
spawn,str+' > DSerrors.dat'
data=get_data('DSerrors.dat')
a=reform(data(0,*))
b=reform(data(1,*))
idx=where(a gt 0 and b gt 0)
data=data(*,idx)
a=reform(data(0,*))
b=reform(data(1,*))
c=reform(data(2,*))
d=reform(data(3,*))
n=n_elements(a)
print,'n=',n
openw,4,'p.dat'
for i=0,n-1,1 do begin
if (a(i) lt b(i) and c(i) ne 0) then printf,4,c(i)
if (a(i) ge b(i) and d(i) ne 0) then printf,4,d(i)
endfor
close,4
data=get_data('p.dat')
return
end

!P.MULTI=[0,2,2]
!P.THICK=2
!P.CHARSIZE=1.1
str='RAW'
getit,str,data
histo,data,-1,10,0.3,xtitle='Error in % on DS for '+str
print,'Median error in %:',median(data),' for '+str
xyouts,-1,0.9*max([!Y.crange]),'Median error in %:'+string(median(data),format='(f4.2)')
str='EFM'
getit,str,data
histo,data,-1,10,0.3,xtitle='Error in % on DS for '+str
print,'Median error in %:',median(data),' for '+str
xyouts,-1,0.9*max([!Y.crange]),'Median error in %:'+string(median(data),format='(f4.2)')
str='BBSOlin'
getit,str,data
histo,data,-1,10,0.3,xtitle='Error in % on DS for '+str
print,'Median error in %:',median(data),' for '+str
xyouts,-1,0.9*max([!Y.crange]),'Median error in %:'+string(median(data),format='(f4.2)')
str='BBSOlog'
getit,str,data
histo,data,-1,10,0.3,xtitle='Error in % on DS for '+str
print,'Median error in %:',median(data),' for '+str
xyouts,-1,0.9*max([!Y.crange]),'Median error in %:'+string(median(data),format='(f4.2)')
end
