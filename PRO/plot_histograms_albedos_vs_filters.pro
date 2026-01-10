PRO goget_albedo,file,filterstr,whattogetstr,albedoB
if (whattogetstr eq 'contrast') then begin
xmin=0.5
xmax=1.4
spawn,'grep '+filterstr+' '+file+" | awk '$10 <0.2 {print $9}' > p.dat"
data=get_data('p.dat')
print,'Min,Max data: ',min(data),max(data)
idx=where(data gt xmin and data lt xmax)
data=data(idx)
histo,/abs,data,xmin,xmax,(xmax-xmin)/90.,xtitle=filterstr+' Albedo!dcontrast!n'
oplot,[median(data),median(data)],[!Y.crange],linestyle=2
print,filterstr+' median '+whattogetstr+'= ',median(data)
endif
if (whattogetstr eq 'corefactor') then begin
xmin=0.0
xmax=10.7
spawn,'grep '+filterstr+' '+file+" | awk '$10 <1 {print $8}' > p.dat"
data=get_data('p.dat')
print,'Min,Max data: ',min(data),max(data)
idx=where(data gt xmin and data lt xmax)
data=data(idx)
histo,/abs,data,xmin,xmax,(xmax-xmin)/90.,xtitle=filterstr+' f!dcore!n'
oplot,[median(data),median(data)],[!Y.crange],linestyle=2
print,filterstr+' median '+whattogetstr+'= ',median(data)
endif
if (whattogetstr eq 'alfa') then begin
xmin=0.2
xmax=2.7
spawn,'grep '+filterstr+' '+file+" | awk '$10 <1 {print $4}' > p.dat"
data=get_data('p.dat')
print,'Min,Max data: ',min(data),max(data)
idx=where(data gt xmin and data lt xmax)
data=data(idx)
histo,/abs,data,xmin,xmax,(xmax-xmin)/90.,xtitle=filterstr+' !7a!3'
oplot,[median(data),median(data)],[!Y.crange],linestyle=2
print,filterstr+' median '+whattogetstr+'= ',median(data)
endif
if (whattogetstr eq 'albedo') then begin
xmin=0.2
xmax=0.7
spawn,'grep '+filterstr+' '+file+" | awk '$10 <1 {print $2}' > p.dat"
data=get_data('p.dat')
print,'Min,Max data: ',min(data),max(data)
idx=where(data gt xmin and data lt xmax)
data=data(idx)
histo,/abs,data,xmin,xmax,(xmax-xmin)/90.,xtitle=filterstr+' albedo'
oplot,[median(data),median(data)],[!Y.crange],linestyle=2
print,filterstr+' median '+whattogetstr+'= ',median(data)
endif
return
end

; JD,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,corefactor,contrast,RMSE,totfl
!P.CHARSIZE=2
!P.MULTI=[0,1,5]
file='NEW_TEST_CONTINUED.CLEM.profiles_fitted_results_April_24_2013.txt'
file='CLEM.profiles_fitted_results_April_2014_morebands.txt'
goget_albedo,file,'_B_','albedo',albedoB
goget_albedo,file,'_V_','albedo',albedoV
goget_albedo,file,'_VE1_','albedo',albedoVE1
goget_albedo,file,'_IRCUT_','albedo',albedoIRCUT
goget_albedo,file,'_VE2_','albedo',albedoVE2
;
goget_albedo,file,'_B_','alfa',alfaB
goget_albedo,file,'_V_','alfa',alfaV
goget_albedo,file,'_VE1_','alfa',alfaVE1
goget_albedo,file,'_IRCUT_','alfa',alfaIRCUT
goget_albedo,file,'_VE2_','alfa',alfaVE2
;
strwanted='corefactor'
goget_albedo,file,'_B_',strwanted,corefactorB
goget_albedo,file,'_V_',strwanted,corefactorV
goget_albedo,file,'_VE1_',strwanted,corefactorVE1
goget_albedo,file,'_IRCUT_',strwanted,corefactorIRCUT
goget_albedo,file,'_VE2_',strwanted,corefactorVE2
;
strwanted='contrast'
goget_albedo,file,'_B_',strwanted,contrastB
goget_albedo,file,'_V_',strwanted,contrastV
goget_albedo,file,'_VE1_',strwanted,contrastVE1
goget_albedo,file,'_IRCUT_',strwanted,contrastIRCUT
goget_albedo,file,'_VE2_',strwanted,contrastVE2
end
