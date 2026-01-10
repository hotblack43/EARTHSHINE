 PRO get_monphase,header,monphase
 idx=where(strpos(header, 'MPHASE') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 monphase=float(strmid(str,13,13))
 return
 end

 PRO get_JD,header,JD
 idx=where(strpos(header, 'JULIAN') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 JD=float(strmid(str,13,16))
 return
 end

PRO getstufffromheader,header,monphase,jd,k
get_JD,header,JD
get_monphase,header,monphase
mphase,jd,k
return
end


files=file_search('OUTPUT/IDEAL/ideal_*',count=n)
openw,33,'LUNAR_PHASE_AND_ILLFRAC.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),header,/sil)
getstufffromheader,header,monphase,jd,k
if (jd gt 2455920.001d0 and jd lt 2455949.6) then printf,33,format='(f17.6,1x,f5.3,1x,f9.4)',jd,k,monphase
endfor
close,33
data=get_data('LUNAR_PHASE_AND_ILLFRAC.dat')
jd=reform(data(0,*))
k=reform(data(1,*))
ph=reform(data(2,*))
!P.MULTI=[0,1,2]
plot,jd,k
plot,jd,ph
end
