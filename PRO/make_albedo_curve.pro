for nyears=10,30,10 do begin
openw,2,strcompress('slopes_'+string(fix(nyears))+'.dat',/remove_all)
nMC=300
for iMC=0,nMC-1,1 do begin
data=reform(get_data('albedo.mean'))
factor=0.05/65.
albedo=data*factor
nmonths=12.*nyears
nsamples=nyears*100.	; number of random samples taken
for i=0,nyears-1,1 do albedo=[albedo,data*factor]
;noise=randomn(seed,nmonths)*0.001	; from Bender et al 2006 Figure 2 bottom panel.
noise=randomn(seed,nmonths)*0.003	; from daily-mean global-average CERES data
print,'SD noise: ',stddev(noise)
albedo=albedo+noise
albedo=albedo+0.3
time=findgen(nmonths)*365.25/12.; day number
plot,time mod 365.25/12.,albedo
; generate daily data
day=findgen(nyears*365.25)
;..............................
;ramp=1.0+day/365.25*0.001
;albedo=albedo*ramp
;..............................
alb=INTERPOL(albedo,time,day)
!P.CHARSIZE=2
plot,day,alb,ystyle=3,xstyle=3,xtitle='Day',ytitle='Albedo and samples'
res=linfit(day,alb,/double,yfit=yhat,sigma=sigs)
oplot,time,yhat
print,'Using all data:'
print,res(0),' +/- ',sigs(0)
print,res(1),' +/- ',sigs(1)
print,'Slope is : ',abs(res(1)*nyears*365.25/mean(albedo))*100.,' % of the albedo over the period of interest'
err1=(res(1)*nyears*365.25/mean(albedo))*100.
;-----------------------------------------------------------------------------
; for the sample
sample_points=randomu(seed,nsamples)*max(day)
a_sampled=interpol(alb,day,sample_points)
res=linfit(sample_points,a_sampled,/double,yfit=yhat,sigma=sigs)
oplot,sample_points,yhat,color=fsc_color('red')
print,'Using sample:'
print,res(0),' +/- ',sigs(0)
print,res(1),' +/- ',sigs(1)
print,'Slope is : ',abs(res(1)*nyears*365.25/mean(albedo))*100.,' % of the albedo over the period of interest'
oplot,sample_points,a_sampled,psym=7
err2=(res(1)*nyears*365.25/mean(albedo))*100.
printf,2,err1,err2
endfor
close,2
endfor
end
