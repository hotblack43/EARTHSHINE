




 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end

PRO get_JD_from_filename,name,JD
JD=double(strmid(name,strpos(name,'24'),15))
return
end

PRO getdata,files,jd,am,flux
n=n_elements(files)
Blisten=[]
for i=0,n-1,1 do begin
im=readfits(files(i),header,/sil)
l=size(im)
if (l(0) ne 2) then stop
get_EXPOSURE,header,texp
get_JD_from_filename,files(i),JD
mlo_airmass,jd,am
;print,format='(f15.7,1x,f8.4,1x,g20.10)',jd,am,total(im,/double)/texp
Blisten=[[Blisten],[jd,am,total(im,/double)/texp]]
endfor
jd=reform(Blisten(0,*))
am=reform(Blisten(1,*))
flux=reform(Blisten(2,*))
return
end

FUNCTION mags,flux
mags=-2.5*alog10(flux)
return,mags
end

PRO get_k,jd,am,flux,midJD,k,kerr
; first find unique nights
midJD=[]
k=[]
kerr=[]
sigserr=0.01
for iJD=min(long(JD))-0.5,max(long(JD))+0.5,1.0d0 do begin
idx=where(jd ge iJD and jd lt iJD+1)
if (n_elements(idx) gt 5) then begin
res=robust_linefit(am(idx),mags(flux(idx)),yhat,ss,sigs)
print,'k = ',res(1),' +/- ',sigs(1)
if (sigs(1) lt sigserr) then begin
midJD=[midJD,iJD]
k=[k,res(1)]
kerr=[kerr,sigs(1)]
endif
endif
endfor
return
end

files=file_search('/data/pth/DARKCURRENTREDUCED/SELECTED_1/*_B_*fit*',count=n)
getdata,files,jdB,amB,fluxB
files=file_search('/data/pth/DARKCURRENTREDUCED/SELECTED_1/*_V_*fit*',count=n)
getdata,files,jdV,amV,fluxV
;
get_k,jdB,amB,fluxB,midJD_B,k_B,kerr_B
get_k,jdV,amV,fluxV,midJD_V,k_V,kerr_V
fmt='(f15.7,a,f9.7,a,f7.5)'
for i=0,n_elements(k_B)-1,1 do begin
print,format=fmt,midJD_B(i),' k_B = ',k_B(i),' +/- ',kerr_B(i)
endfor
for i=0,n_elements(k_V)-1,1 do begin
print,format=fmt,midJD_V(i),' k_V = ',k_V(i),' +/- ',kerr_V(i)
endfor
end
