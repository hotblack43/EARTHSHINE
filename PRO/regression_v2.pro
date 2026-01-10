PRO generate_anomalies,x
; x is assumed to be a monthlys eries with a seasonal signal. The seasonal signal is to be
; removed leaving the anomaly
n=n_elements(x)
;	print,'n=',n
if (n mod 12 ne 0) then stop
idx=indgen(n)
idx=idx mod 12 +1
seasonal=fltarr(12)
icount=0
for i=1,12,1 do begin
jdx=where(idx eq i)
x(jdx)=x(jdx)-mean(x(jdx))
endfor
return
end

;=================================================
; regression_v2.pro
; Version that uses backwards elimination to select 
; set of regressors in each lon,lat
; and produces global maps of results
;=================================================

;.r MC_correlate_AR1
;
year1=1958
year2=2002
restore,filename='NCEP_monthly_thickness_temperature.sav'
set_plot,'ps
device,/color
device,xsize=18,ysize=24.5,yoffset=2
;
;-------------------------------------------------------------
file='AOD.dat'
data=get_data(file)
AOD=reform(data(1,*))
timeAOD=reform(data(0,*))
;
;-------------------------------------------------------------
file='SOI.data'
data=get_data(file)
soi=reform(data(1,*))
timesoi=reform(data(0,*))
soi=shift(soi,3)
;
;-------------------------------------------------------------
file='f10.dat'
data=get_data(file)
timef10=reform(data(0,*))
f10=reform(data(1,*))
f10=f10/1200.	; f10 scaled to 1367 W/m²
;-------------------------------------------------------------
; select time interval
idx=where(timef10 ge year1 and timef10 lt year2)
f10=f10(idx)
idx=where(timeAOD ge year1 and timeAOD lt year2)
AOD=AOD(idx)
idx=where(timesoi ge year1 and timesoi lt year2)
soi=soi(idx)
;-------------------------------------------------------------
idx=where(fracyear_air ge year1 and fracyear_air lt year2)
MEAN_TEMP_500_200=MEAN_TEMP_500_200(*,*,idx)
;-------------------------------------------------------------
;
help,f10,soi,aod
;
nlon=n_elements(lon)
nlat=n_elements(lat)
map_coef=fltarr(nlon,nlat)
map_sigm=fltarr(nlon,nlat)
map_tau=fltarr(nlon,nlat)
map_R=fltarr(nlon,nlat)
map_Rsignif=fltarr(nlon,nlat)
map_SOI=fltarr(nlon,nlat)
map_SOIsig=fltarr(nlon,nlat)
map_lin=fltarr(nlon,nlat)
map_linsig=fltarr(nlon,nlat)
map_AOD=fltarr(nlon,nlat)
map_AODsig=fltarr(nlon,nlat)
exist_map=fltarr(4,nlon,nlat)
array1=f10
n_MC=799
iflag=1
list=indgen(n_elements(f10))
generate_anomalies,f10
;generate_anomalies,list
generate_anomalies,soi
generate_anomalies,AOD
icount=0
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
;	y=THICKNESS_500_200(ilon,ilat,*)
	y=MEAN_TEMP_500_200(ilon,ilat,*)
	generate_anomalies,y
	xx=transpose([[f10],[list],[soi],[AOD]])
	yy=reform(transpose(y))
;	res=regress(xx,yy,sigma=sigs,/double,yfit=yfit,const=const)
 	siglev=0.05
 	res = backw_elim(xx,reform(transpose(y)),sigma=sigs,/double,yfit=yfit,const=const, siglev,varlist=varlist )
	exist_map(varlist,ilon,ilat)=1
	kdx=where(varlist eq 0)
	if (kdx(0) ne -1) then begin
	map_coef(ilon,ilat)=res(kdx)
	map_sigm(ilon,ilat)=sigs(kdx)
	endif
	kdx=where(varlist eq 1)
	if (kdx(0) ne -1) then begin
	map_lin(ilon,ilat)=res(kdx)
	map_linsig(ilon,ilat)=sigs(kdx)
	endif
	kdx=where(varlist eq 2)
	if (kdx(0) ne -1) then begin
	map_SOI(ilon,ilat)=res(kdx)
	map_SOIsig(ilon,ilat)=sigs(kdx)
	endif
	kdx=where(varlist eq 3)
	if (kdx ne -1) then begin
	map_AOD(ilon,ilat)=res(kdx)
	map_AODsig(ilon,ilat)=sigs(kdx)
	endif
	ac1=a_correlate(y-yfit,1)
	tau=(1.+ac1)/(1.-ac1)
	map_tau(ilon,ilat)=tau
	jdx=where(varlist ne 0)
 	if (n_elements(jdx) gt 1) then array2=reform(y-(const+res[varlist(jdx)]#xx[varlist(jdx),*]))
 	if (n_elements(jdx) eq 1 and jdx(0) eq -1) then array2=reform(y-(const+res[varlist]#xx[varlist,*]))
	MC_correlate_AR1,rebin(array1,n_elements(array1)/12),rebin(array2,n_elements(array2)/12),MC_siglevel,n_MC,R,iflag
	map_R(ilon,ilat)=R
	map_Rsignif(ilon,ilat)=100.-MC_siglevel
endfor
print,ilon
endfor
!P.MULTI=[0,1,2]
loadct,39
print,'Max,min of Solar irradiance regression coefficient:',max(map_coef),min(map_coef)
map_set,title='TSI regression coefficient - K/(W/m²) [0.1 K/W/m² spacing, S/N bold at 3 ]'
contour,map_coef,lon,lat,nlevels=101,/cell_fill,/overplot
levels=indgen(21)*0.1-1.0
c_thick=indgen(n_elements(levels))*0+1
c_labels=indgen(n_elements(levels))*0+1
;c_thick(where(levels eq 0))=5
contour,map_coef,lon,lat,levels=levels,c_thick=c_thick,/overplot,c_labels=c_labels
map_continents,/overplot
; over plot S/N as thick contours
levels=[3]
c_thick=indgen(n_elements(levels))*0+5
contour,abs(map_coef/map_sigm),lon,lat,levels=levels,c_thick=c_thick,/overplot,/DOWNHILL

;map_set,title='coeff/sigma - unit spacing, 3 bold',/ADVANCE
;print,'Max,min of S/N for TSI:',max(abs(map_coef/map_sigm)),min(abs(map_coef/map_sigm))
;contour,abs(map_coef/map_sigm),lon,lat,nlevels=101,/cell_fill,/overplot
;levels=[-1,0,1,2,3,4,5,6,7,8,9]
;c_thick=indgen(n_elements(levels))*0+1
;c_thick(where(levels eq 3))=5
;contour,map_coef/map_sigm,lon,lat,levels=levels,c_thick=c_thick,/overplot
;map_continents,/overplot


!P.MULTI=[0,1,2]
map_set,title='linear term regression coeff - [ thin contours, thick S/N at 3]',/ADVANCE
print,'Max,min of linear term:',max(map_lin),min(map_lin)
contour,map_lin,lon,lat,nlevels=101,/cell_fill,/overplot
levels=[0,indgen(11)*(0.08+0.05)/11.-0.05]
levels=levels(sort(levels))
c_thick=indgen(n_elements(levels))*0+1
;c_thick(where(levels eq 0))=5
contour,map_lin,lon,lat,levels=levels,c_thick=c_thick,/overplot
map_continents,/overplot
; over plot S/N as thick contours
levels=[3]
c_thick=indgen(n_elements(levels))*0+5
SNmap=abs(map_lin/map_linsig)
contour,SNmap,lon,lat,levels=levels,c_thick=c_thick,/overplot,/DOWNHILL

;SNmap=abs(map_lin/map_linsig)
;map_set,title='linear term coefficient S/N - [3 bold]',/ADVANCE
;print,'Max,min of linear S/N:',max(SNmap),min(SNmap)
;contour,SNmap,lon,lat,nlevels=101,/cell_fill,/overplot
;levels=[0,1,2,3,6,9,12,15,18,21]
;c_thick=indgen(n_elements(levels))*0+1
;c_thick(where(levels eq 3))=5
;contour,SNmap,lon,lat,levels=levels,c_thick=c_thick,/overplot
;map_continents,/overplot

!P.MULTI=[0,1,2]
map_set,title='AOD coefficient - [thin contours, thick S/N at 3]',/ADVANCE
print,'Max,min of AOD term:',max(map_AOD),min(map_AOD)
contour,map_AOD,lon,lat,nlevels=101,/cell_fill,/overplot
levels=[0,indgen(11)*(13+8)/11.-13]
levels=levels(sort(levels))
c_thick=indgen(n_elements(levels))*0+1
;c_thick(where(levels eq 0))=5
contour,map_AOD,lon,lat,levels=levels,c_thick=c_thick,/overplot
map_continents,/overplot
; over plot S/N as thick contours
levels=[3]
c_thick=indgen(n_elements(levels))*0+5
SNmap=abs(map_AOD/map_AODsig)
contour,SNmap,lon,lat,levels=levels,c_thick=c_thick,/overplot,/DOWNHILL

;SNmap=abs(map_AOD/map_AODsig)
;map_set,title='AOD coefficient S/N - [3 bold]',/ADVANCE
;print,'Max,min of AOD S/N:',max(SNmap),min(SNmap)
;contour,SNmap,lon,lat,nlevels=101,/cell_fill,/overplot
;levels=[0,1,2,3,4,5,6,7,8,9]
;c_thick=indgen(n_elements(levels))*0+1
;c_thick(where(levels eq 3))=5
;contour,SNmap,lon,lat,levels=levels,c_thick=c_thick,/overplot
;map_continents,/overplot

!P.MULTI=[0,1,2]
map_set,title='SOI coefficient - [thin contours, thick S/N at 3]',/ADVANCE
print,'Max,min of SOI term:',max(map_SOI),min(map_SOI)
contour,map_SOI,lon,lat,nlevels=101,/cell_fill,/overplot
levels=[0,indgen(11)*(0.6+0.2)/11.-0.6]
levels=levels(sort(levels))
c_thick=indgen(n_elements(levels))*0+1
c_thick(where(levels eq 0))=5
contour,map_SOI,lon,lat,levels=levels,c_thick=c_thick,/overplot
map_continents,/overplot
; over plot S/N as thick contours
levels=[3]
c_thick=indgen(n_elements(levels))*0+5
SNmap=abs(map_SOI/map_SOIsig)
contour,SNmap,lon,lat,levels=levels,c_thick=c_thick,/overplot,/DOWNHILL


!P.MULTI=[0,1,2]
map_set,title='Residual Tau - decorrelation time in months [1 mo spacing, 2 bold]'
print,'Max,min of Tau:',max(map_tau),min(map_tau)
contour,map_tau,lon,lat,nlevels=101,/cell_fill,/overplot
levels=[0,1,2,3,4,5,6,7,8,9,10,11,12,13]
c_thick=indgen(n_elements(levels))*0+1
c_thick(where(levels eq 2))=5
contour,map_tau,lon,lat,levels=levels,c_thick=c_thick,/overplot
map_continents,/overplot

!P.MULTI=[0,1,2]
map_set,title='R - non-solar residuals vs. TSI [0.1 spacing, 0 bold]'
print,'Max,min of R:',max(map_R),min(map_R)
levels = [-0.80,-0.75,-0.70,-0.65,-0.60,-0.55,-0.50,-0.45,-0.40,-0.35,-0.30,-0.25,-0.20,-0.15,-0.10,-0.05,0.00,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.45,0.50,0.55,0.60,0.65,0.70,0.75]
colours = [19,19,37,37,56,56,65,65,74,74,84,84, 93,93,112,112, 186,186,191,191, 200,200,210,210,220,220,225,225,235,235,245,245]
contour,map_R,lon,lat,levels=levels,c_colors=colours,/cell_fill,/overplot
levels=indgen(21)*0.1-1.0
c_thick=indgen(n_elements(levels))*0+1
c_thick(where(levels eq 0))=5
contour,map_R,lon,lat,levels=levels,c_thick=c_thick,/overplot
map_continents,/overplot

map_set,title='R significance - [90% bold, red higher]',/ADVANCE
print,'Max,min of R signif:',max(map_Rsignif),min(map_Rsignif)
contour,map_Rsignif,lon,lat,nlevels=101,/cell_fill,/overplot
levels=[0,90,99,99.9,99.99,99.999,100]
c_thick=[1,5,1,1]
contour,map_Rsignif,lon,lat,levels=levels,c_thick=c_thick,/overplot
map_continents,/overplot

!P.MULTI=[0,1,2]
map_set,title='Map of significant regression variable 1: f10'
contour,exist_map(0,*,*),lon,lat,levels=[-1,1,2],c_colors=[255,70,70],/cell_fill,/overplot
map_continents,/overplot
map_set,title='Map of significant regression variable 2: linear term',/ADVANCE
contour,exist_map(1,*,*),lon,lat,levels=[-1,1,2],c_colors=[255,70,70],/cell_fill,/overplot
map_continents,/overplot
map_set,title='Map of significant regression variable 3: SOI',/ADVANCE
contour,exist_map(2,*,*),lon,lat,levels=[-1,1,2],c_colors=[255,70,70],/cell_fill,/overplot
map_continents,/overplot
map_set,title='Map of significant regression variable 4: AOD',/ADVANCE
contour,exist_map(3,*,*),lon,lat,levels=[-1,1,2],c_colors=[255,70,70],/cell_fill,/overplot
map_continents,/overplot
map_set,title='All significant at same time',/ADVANCE
contour,exist_map(0,*,*)*exist_map(1,*,*)*exist_map(2,*,*)*exist_map(3,*,*),lon,lat,levels=[-1,1,2],c_colors=[255,70,70],/cell_fill,/overplot
map_continents,/overplot
end
