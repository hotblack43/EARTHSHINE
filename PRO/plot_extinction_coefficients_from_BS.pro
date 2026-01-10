!P.MULTI=[0,1,2]
file='extinction_coefficients_from_BS.dat'
fnames=['B','V','VE1','VE2','IRCUT']
; first for all nights as determined by regression
d=get_data(file)
plot,xstyle=3,ystyle=3,d(0,*),xtickname=fnames,d(2,*),xtitle='Filter',ytitle='k',psym=7,title='Extinction coefficients from BS - all nights'
kbar=fltarr(5)
print,'All Nights:'
for j=0,4,1 do begin
jdx=where(d(0,*) eq j)
kbar(j)=median(d(2,where(d(0,*) eq j)))
print,format='(a16,f6.3,a,f6.3)','Median k'+fnames(j)+' : ',kbar(j),' SDm : ',stddev(d(2,jdx))/sqrt(n_elements(jdx)-1)
endfor
; now see if each night is just an offset from some mean
; get the uniq JDs
uJD=d(1,*)
uJD=uJD(sort(uJD))
uJD=uJD(uniq(uJD))
openw,44,'atleast5_extinction_coefficients_from_BS.dat'
for k=0,n_elements(uJD)-1,1 do begin
idx=where(d(1,*) eq uJD(k))
if (n_elements(idx) ge 5)then begin
print,'Uniq JD: ',uJD(k),n_elements(idx)
for m=0,n_elements(idx)-1,1 do printf,44,d(*,idx(m))
endif
endfor
close,44
file='atleast5_extinction_coefficients_from_BS.dat'
d=get_data(file)
plot,xstyle=3,ystyle=3,d(0,*),xtickname=fnames,$
d(2,*),xtitle='Filter',ytitle='k',psym=7,title='Extinction coefficients from BS - complete nights'
kbar=fltarr(5)
print,'Complete Nights:'
for j=0,4,1 do begin
jdx=where(d(0,*) eq j)
kbar(j)=median(d(2,jdx))
print,format='(a16,f6.3,a,f6.3)','Median k'+fnames(j)+' : ',kbar(j),' SDm : ',stddev(d(2,jdx))/sqrt(n_elements(jdx)-1)
endfor

end
