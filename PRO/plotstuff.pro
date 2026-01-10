!P.CHARSIZE=1.3
!P.THICK=3
!x.THICK=3
!y.THICK=3
file='WILD.profiles_fitted_results.txt'
file='CLEM.profiles_fitted_results.txt'
fnames=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
openw,66,strcompress('Best_selected_data.tex',/remove_all)
printf,66,'\begin{table}'
printf,66,'\centering'
printf,66,'\caption{Table of best results.}'
printf,66,'\begin{tabular}{lllrcrl}\hline'
printf,66,'JD & Albedo & Alb. err & $\alpha$ & Pedestal& RMSE & Filter\\\hline'

for ifilter=0,4,1 do begin
!P.MULTI=[0,3,3]
print,'Filter: ',fnames(ifilter)
spawn,"cat "+file+" | grep "+fnames(ifilter)+" | awk '{print $1,$2,$3,$4,$5,$6,$7}' > p"
data=get_data('p')
JD=reform(data(0,*))
albedo=reform(data(1,*))
erralbedo=reform(data(2,*))
alfa=reform(data(3,*))
pedestal=reform(data(4,*))
xshift=reform(data(5,*))
rmse=reform(data(6,*))
print,'Before selection mean log10(RMSE) is: ',mean(alog10(rmse))
idx=where((alfa gt 1.65 and alfa lt 1.77) and (erralbedo/albedo*100. lt 2.0) and (alog10(rmse) lt -0.3))
print,'N selected for alfa       : ',n_elements(where(alfa gt 1.65))
print,'N selected for rel alb err: ',n_elements(where(erralbedo/albedo*100. lt 2.0))
print,'N selected for RMSE       : ',n_elements(where(alog10(rmse) lt -0.3))
print,'N selected for all above  : ',n_elements(idx)
data=data(*,idx)
JD2=reform(data(0,*))
albedo2=reform(data(1,*))
erralbedo2=reform(data(2,*))
alfa2=reform(data(3,*))
pedestal2=reform(data(4,*))
xshift2=reform(data(5,*))
rmse2=reform(data(6,*))
print,'After selection mean log10(RMSE) is: ',mean(alog10(rmse2))
;usethis1=fsc_color('white')
usethis1=fsc_color('black')
;..................
!P.color=usethis1
histo,albedo,0,1,0.01,xtitle='Albedo',/abs,title=fnames(ifilter)+file
!P.COLOR=fsc_color('red')
histo,/overplot,albedo2,0,1,0.01,/abs
;..................
!P.color=usethis1
histo,erralbedo,0,0.03,0.001,xtitle=' Absolute Albedo Error',/abs,title=fnames(ifilter)+file
!P.COLOR=fsc_color('red')
histo,/overplot,erralbedo2,0,0.03,0.001,/abs
;..................
!P.color=usethis1
histo,erralbedo/albedo*100.,0,8,0.1,xtitle='Relative Albedo Error [%]',/abs,title=fnames(ifilter)+file
!P.COLOR=fsc_color('red')
histo,/overplot,erralbedo2/albedo2*100.,0,8,0.1,/abs
;..................
!P.color=usethis1
histo,alfa,1.4,2.0,0.01,xtitle='!7a!3',/abs,title=fnames(ifilter)+file
!P.COLOR=fsc_color('red')
histo,/overplot,alfa2,1.4,2.0,0.01,/abs
;..................
!P.color=usethis1
histo,pedestal,-10,40,0.1,xtitle='Pedestal',/cum,title=fnames(ifilter)+file
!P.COLOR=fsc_color('red')
histo,/overplot,pedestal2,-10,40,0.1,/cum
;..................
!P.color=usethis1
histo,xshift,-10,10,0.1,xtitle='!7D!3',/abs,title=fnames(ifilter)+file
!P.COLOR=fsc_color('red')
histo,/overplot,xshift2,-10,10,0.1,/abs
;..................
!P.color=usethis1
histo,alog10(rmse),-1.5,1.0,0.1,xtitle='log!d10!nRMSE',/abs,title=fnames(ifilter)+file
!P.COLOR=fsc_color('red')
histo,/overplot,alog10(rmse2),-1.5,1.0,0.1,/abs
;..................
fmt='(f15.7,a,5(1x,f9.4,a),1x,a,a)'
for i=0,n_elements(idx)-1,1 do begin
printf,66,format=fmt,JD2(i),' &',albedo2(i),' &',erralbedo2(i),' &',alfa2(i),' &',pedestal2(i),' &',rmse2(i),' &',fnames(ifilter),' \\'
print,format=fmt,JD2(i),' ',albedo2(i),' ',erralbedo2(i),' ',alfa2(i),' ',pedestal2(i),' ',rmse2(i),' ',fnames(ifilter)
endfor
endfor	; end filter loop
printf,66,'\end{tabular}'
printf,66,'\end{table}'
close,66
end
