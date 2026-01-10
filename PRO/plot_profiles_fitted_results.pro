FUNCTION get_JD_from_filename,name
liste=strsplit(name,'_',/extract)
idx=strpos(liste,'24')
ipoint=where(idx ne -1)
JD=double(liste(ipoint))
return,JD
end

file='profiles_fitted_results.txt'
filternames=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
for ifilter=0,4,1 do begin
filterstr=filternames(ifilter)
print,filterstr
p='p_'+filterstr
str='grep '+filterstr+' '+file+" | awk '{print $1,$2}' > "+p
spawn,str
thisname='thisname_'+filterstr
str='grep '+filterstr+' '+file+" | awk '{print $5}' > "+thisname
spawn,str
data=get_data(p)
openr,44,thisname
ic=0
while not eof(44) do begin
nam=''
readf,44,nam
JD=get_JD_from_filename(nam)
if (ic eq 0) then JDlist=JD
if (ic gt 0) then JDlist=[JDlist,JD]
ic=ic+1
endwhile
close,44
albedo=reform(data(0,*))
print,albedo
erralbedo=reform(data(1,*))
;
!P.title=filterstr+' on 2456016 and 2456075 (blue)'
!x.title='Fraction of JD'
!y.title='Albedo'
!y.style=3
!P.CHARSIZE=1.6
!P.thick=3
!x.thick=3
!y.thick=3
!P.charthick=3
idx=where(long(JDlist) eq 2456016)
jdx=where(long(JDlist) eq 2456075)
;!Y.range=[0.15,0.45]
!P.color=fsc_color('black')
;!P.color=fsc_color('white')
 ploterr,JDList mod 1,albedo,erralbedo,psym=3
!P.color=fsc_color('red')
oploterr,JDList(idx) mod 1,albedo(idx),erralbedo(idx),1
!P.color=fsc_color('blue')
oploterr,JDList(jdx) mod 1,albedo(jdx),erralbedo(jdx),1
endfor
end
