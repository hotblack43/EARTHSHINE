!P.CHARSIZE=2.3
!P.CHARTHICK=1
file='CLEM.profiles_fitted_results_April_2014_morebands.txt'
file='CLEM.profiles_fitted_results_11bands_045image.txt'
file='CLEM.profiles_fitted_results_11bands_4treatments_ped_and_rlim_fixed.txt'
file='CLEM.profiles_fitted_results_11bands_4treatments_ped_and_rlim_and_corefactor_fixed.txt'
spawn,'cat '+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' > hgfhgv.dat"
data=get_data('hgfhgv.dat')

str=['JD','albedo','erralbedo','alfa1','rlimit','pedestal','xshift','corefactor','contrast','RMSE','totfl']
l=size(data,/dimensions)
n=l(1)
print,n
!P.MULTI=[0,3,3]
idx=where(data(9,*) lt 0.1)
data=data(*,idx)
idx=where(data(9,*) lt 1)
for jcol=1,10,1 do begin
for icol=1,10,1 do begin
if (icol ne jcol) then begin
	plot,data(jcol,*),data(icol,*),psym=7,xtitle=str(jcol),ytitle=str(icol),xstyle=3,ystyle=3
	oplot,data(jcol,idx),data(icol,idx),psym=7,color=fsc_color('red')
endif
endfor
endfor
end
