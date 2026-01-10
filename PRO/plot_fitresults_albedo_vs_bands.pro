!P.CHARSIZE=2.3
!P.CHARTHICK=2

files=['CLEM.profiles_fitted_results_11bands_4treatments_rlimit_fixed.txt',$
'CLEM.profiles_fitted_results_11bands_4treatments_pedestalfixed.txt',$
'CLEM.profiles_fitted_results_11bands_4treatments_ped_and_corefactor_fixed.txt',$
'CLEM.profiles_fitted_results_11bands_4treatments_ped_and_rlim_and_corefactor_fixed.txt',$
'CLEM.profiles_fitted_results_11bands_4treatments_ped_and_rlim_fixed.txt',$
'CLEM.profiles_fitted_results_11bands_4treatments.txt']
nm=n_elements(files)
!P.MULTI=[0,1,nm]
print,'------------------------------------------------------------------'
for ifile=0,nm-1,1 do begin
file=files(ifile)
spawn,'cat '+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' > hgfhgv.dat"
data=get_data('hgfhgv.dat')

str=['JD','albedo','erralbedo','alfa1','rlimit','pedestal','xshift','corefactor','contrast','RMSE','totfl']
l=size(data,/dimensions)
n=l(1)
print,n
sequencenumber=findgen(n)+1
band=findgen(n) mod 11
idx=where(                         sequencenumber le 11 and data(9,*) lt 0.1)
oldcharsize=!P.CHARSIZE
!P.CHARSIZE=1.4
plot,title=file,/nodata,yrange=[0.28,0.325],xstyle=3,ystyle=3,band,data(1,*),psym=7,xtitle='Band #',ytitle='Albedo',color=fsc_color('black')
!P.CHARSIZE=oldcharsize
sh=(randomu(seed,n_elements(band))-0.5)/2.
if (n_elements(idx) gt 1 and idx(0) ne -1 )then oplot,band(idx)+sh(idx),data(1,idx),psym=7,color=fsc_color('black')
idx=where(sequencenumber gt 11 and sequencenumber le 22 and data(9,*) lt 0.1)
if (n_elements(idx) gt 1 and idx(0) ne -1 )then oplot,band(idx)+sh(idx),data(1,idx),psym=7,color=fsc_color('red')
idx=where(sequencenumber gt 22 and sequencenumber le 33 and data(9,*) lt 0.1)
if (n_elements(idx) gt 1 and idx(0) ne -1 )then oplot,band(idx)+sh(idx),data(1,idx),psym=7,color=fsc_color('green')
idx=where(sequencenumber gt 33 and sequencenumber le 44 and data(9,*) lt 0.1)
if (n_elements(idx) gt 1 and idx(0) ne -1 )then oplot,band(idx)+sh(idx),data(1,idx),psym=7,color=fsc_color('orange')
idx=where(sequencenumber gt 44 and sequencenumber le 55 and data(9,*) lt 0.1)
if (n_elements(idx) gt 1 and idx(0) ne -1 )then oplot,band(idx)+sh(idx),data(1,idx),psym=6,color=fsc_color('black')
idx=where(sequencenumber gt 55 and sequencenumber le 66 and data(9,*) lt 0.1)
if (n_elements(idx) gt 1 and idx(0) ne -1 )then oplot,band(idx)+sh(idx),data(1,idx),psym=6,color=fsc_color('red')
idx=where(sequencenumber gt 66 and sequencenumber le 77 and data(9,*) lt 0.1)
if (n_elements(idx) gt 1 and idx(0) ne -1 )then oplot,band(idx)+sh(idx),data(1,idx),psym=6,color=fsc_color('green')
idx=where(sequencenumber gt 77 and sequencenumber le 88 and data(9,*) lt 0.1)
if (n_elements(idx) gt 1 and idx(0) ne -1 )then oplot,band(idx)+sh(idx),data(1,idx),psym=6,color=fsc_color('orange')
print,'------------------------------------------------------------------'
endfor
end
