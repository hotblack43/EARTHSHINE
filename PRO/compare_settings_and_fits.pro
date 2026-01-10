PRO gomakehisto,x,str
z=x(sort(x))
n=n_elements(x)
z=z(n*0.1:n*0.9)
sd=stddev(z)
histo,x,median(x)-3.*sd,median(x)+3.*sd,sd/5.,xtitle=str,/abs
return
end

PRO report_derivatives,x,y,str
delta_x=mean(abs(x))
COEFF = ROBUST_LINEFIT( X, Y, YFIT, SIG, COEF_SIG)
if (abs(coef_sig(1)/abs(coeff(1)) lt 1./3.)) then oplot,x,yfit,color=fsc_color('red')
fmt='(a18,f9.6,a,f9.6,a39,f9.6,a,f9.6,a,f5.2,a)'
print,format=fmt,' dA*/d_'+str+' =',coeff(1),' +/- ',coef_sig(1),' or, given typical d_'+str+'= ',delta_x,' : ',coeff(1)*delta_x,' or ',abs(coeff(1)*delta_x)/0.3*100,' %.'
return
end

openw,33,'fits.dat'
file='settings_trial.dat'
settings=get_data(file)
namestr=reform(fix(settings(0,*)))
pedestal=reform((settings(1,*)))
ZLplusSL=reform((settings(2,*)))
rlimit=reform((settings(3,*)))
corefactor=reform((settings(4,*)))
alfa1=reform((settings(5,*)))
contrast=reform((settings(6,*)))
albedo=reform((settings(7,*)))
n=n_elements(namestr)
CLEMfile='CLEM.profiles_fitted_results_multipatch_TRIALIMAGES_cffixedat10when10isanswer.txt'
CLEMfile='CLEM.profiles_fitted_results_multipatch_TRIALIMAGES_cffixedat1when10isanswer.txt'
CLEMfile='CLEM.profiles_fitted_results_fan_TEST.txt'
print,"  pedestal           corefactor           alfa                contrast            albedo              ZL+SL"
print,"  setting   fit      setting    fit       setting   fit       setting   fit       setting   fit       setting   fit"
for i=0,n-1,1 do begin
spawn,'touch  block.dat'
spawn,'rm block.dat'
st=strcompress("trial_"+string(namestr(i)),/remove_all)
str="grep "+st+" "+CLEMfile+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > block.dat "
spawn,str
res=file_info('block.dat')
if (res.size ne 0) then begin
fitted=get_data('block.dat')
fit_JD=fitted(0)
fit_albedo=fitted(1)
fit_erralbedo=fitted(2)
fit_alfa1=fitted(3)
fit_rlimit=fitted(4)
fit_pedestal=fitted(5)
fit_xshift=fitted(6)
fit_yshift=fitted(7)
fit_corefactor=fitted(8)
fit_contrast=fitted(9)
fit_RMSE=fitted(10)
fit_totfl=fitted(11)
fit_ZLplusSL=fitted(12)+fitted(13)
print,format='(12(1x,f9.6))',pedestal(i),fit_pedestal,corefactor(i),fit_corefactor,alfa1(i),fit_alfa1,contrast(i),fit_contrast,albedo(i),fit_albedo,ZLplusSL(i),fit_ZLplusSL
printf,33,format='(12(1x,f9.6))',pedestal(i),fit_pedestal,corefactor(i),fit_corefactor,alfa1(i),fit_alfa1,contrast(i),fit_contrast,albedo(i),fit_albedo,ZLplusSL(i),fit_ZLplusSL
endif
endfor
close,33
data=get_data('fits.dat')
d_pedestal=data(0,*)-data(1,*)
d_corefactor=data(2,*)-data(3,*)
d_alfa=data(4,*)-data(5,*)
d_contrast=data(6,*)-data(7,*)
d_albedo=data(8,*)-data(9,*)
d_backgrnd=data(10,*)-data(11,*)
!P.CHARSIZE=1.6
!P.THICK=4
!x.THICK=3
!y.THICK=3
!P.MULTI=[0,2,2]
set_plot,'ps'
device,/landscape,/color
plot,ystyle=3,d_alfa,d_albedo,psym=7,xtitle='!7Da!3',ytitle='!7D!3 A*'
report_derivatives,d_alfa,d_albedo,'alfa'
plot,ystyle=3,d_backgrnd,d_albedo,psym=7,xtitle='!7D!3 ZL+SL',ytitle='!7D!3 A*'
report_derivatives,d_backgrnd,d_albedo,'ZL+SL'
plot,ystyle=3,d_contrast,d_albedo,psym=7,xtitle='!7D!3 contrast',ytitle='!7D!3 A*'
report_derivatives,d_contrast,d_albedo,'contrast'
plot,ystyle=3,d_pedestal,d_albedo,psym=7,xtitle='!7D!3 pedestal',ytitle='!7D!3 A*'
report_derivatives,d_pedestal,d_albedo,'pedestal'

plot,ystyle=3,d_contrast,d_backgrnd,psym=7,xtitle='!7D!3 contrast',ytitle='!7Da!3 ZL+SL'
plot,ystyle=3,d_pedestal,d_alfa,psym=7,xtitle='!7D!3 pedestal',ytitle='!7Da!3'
plot,ystyle=3,d_pedestal,d_contrast,psym=7,xtitle='!7D!3 pedestal',ytitle='!7D!3 contrast'
plot,ystyle=3,d_pedestal,d_backgrnd,psym=7,xtitle='!7D!3 pedestal',ytitle='!7D!3 ZL+SL'

plot,ystyle=3,d_alfa,d_contrast,psym=7,xtitle='!7Da!3',ytitle='!7D!3 contrast'
plot,ystyle=3,d_alfa,d_backgrnd,psym=7,xtitle='!7Da!3',ytitle='!7D!3 ZL+SL'
fmt='(a,2(1x,f9.4),a,f4.1)'
print,format=fmt,'N : ',n_elements(d_albedo)
print,format=fmt,'Mean & S.D. of d_albedo   : ',mean(d_albedo),stddev(d_albedo),', or Z= ',1./abs(stddev(d_albedo)/mean(d_albedo))
print,format=fmt,'Mean & S.D. of d_alfa     : ',mean(d_alfa),stddev(d_alfa),', or Z= ',1./abs(stddev(d_alfa)/mean(d_alfa))
print,format=fmt,'Mean & S.D. of d_backgrnd : ',mean(d_backgrnd),stddev(d_backgrnd),', or Z= ',1./abs(stddev(d_backgrnd)/mean(d_backgrnd))
print,format=fmt,'Mean & S.D. of d_contrast: ',mean(d_contrast),stddev(d_contrast),', or Z= ',1./abs(stddev(d_contrast)/mean(d_contrast))
print,format=fmt,'Mean & S.D. of d_pedestal: ',mean(d_pedestal),stddev(d_pedestal),', or Z= ',1./abs(stddev(d_pedestal)/mean(d_pedestal))
;
gomakehisto,d_albedo,'!7D!3 A*'
gomakehisto,d_alfa,'!7Da!3'
gomakehisto,d_pedestal,'!7D!3 pedestal'
gomakehisto,d_contrast,'!7D!3 contrast'
gomakehisto,d_backgrnd,'!7D!3 ZL+SL'
end

