FUNCTION FUNC,M,N
;part1=2.01e-5*(m*n)^0.75
;part2=5.31e-15*m*(m*n)^1.52
 FUNC=0.47*alog(1.0+2.01e-5*(m*n)^0.75+5.31e-15*m*(m*n)^1.52)
;FUNC=0.47*alog(1.0+part1+part2)
;print,'====================================='
;print,'m:',m
;print,'n:',n
;print,'part1:',part1
;print,'part2:',part2
;print,'====================================='
return,FUNC
end

FUNCTION N2OFORCING,N2Oppb
CH4_0=N2Oppb*0.0+700.0	;ppbv
N2O_0=N2Oppb*0.0+270.0
alfa=0.12	; IPCC
N2OFORCING=alfa*(sqrt(N2Oppb)-sqrt(N2O_0)) - (func(CH4_0,N2Oppb) - func(CH4_0,N2O_0))
return,N2OFORCING
end

FUNCTION CO2FORCING,CO2ppmv,iflag
CO2_0=278.0
if (iflag eq 1) then alfa=6.3	; IPCC
if (iflag eq 2) then alfa=5.35	; Myhreteal GRL 1998
CO2FORCING=alfa*alog(CO2ppmv/CO2_0)
return,CO2FORCING
end


FUNCTION CH4FORCING,CH4ppbv,N2Oppbv,iflag
CH4_0=CH4ppbv*0.0+700.0	;ppbv
N2O_0=N2Oppbv*0.0+270.0
if (iflag eq 1) then alfa=0.036	; IPCC
if (iflag eq 2) then alfa=0.036	; Myhreteal GRL 1998
CH4FORCING=alfa*(sqrt(CH4ppbv)-sqrt(CH4_0)) - (func(CH4ppbv,N2O_0) - func(CH4_0,N2O_0))
return,CH4FORCING
end


FUNCTION CFCFORCING,F11ppb,F12ppb
F11ppb_0=0.0
F12ppb_0=0.0
alfa_11=0.25	; IPCC Sci.Bas. p.358
alfa_12=0.32	; IPCC Sci.Bas. p.358
CFCFORCING=alfa_11*(F11ppb-F11ppb_0)+alfa_12*(F12ppb-F12ppb_0)
return,CFCFORCING
end

file='C:\Documents and Settings\Peter Thejll\My Documents\WORK\ROBERTSON_GHG_noheader.dat'
data=get_data(file)
year=reform(data(0,*))
CO2=reform(data(1,*))
CH4=reform(data(2,*))
N2O=reform(data(3,*))
iflag=1
F_CO2=CO2FORCING(co2,iflag)
F_CH4=CH4FORCING(CH4,n2o,iflag)
F_N2O=N2OFORCING(n2o)
; CFCs
file='C:\Documents and Settings\Peter Thejll\My Documents\WORK\ROBERTSON_2001_CFC.noheader'
data=get_dataXX(file)
F11=reform(data(1,*))/1d3
F12=reform(data(2,*))/1d3
CFCFORC=CFCFORCING(F11,F12)
total_GHG_forcing=F_CO2+F_CH4+F_N2O+CFCFORC
; get Sun and V.
file='C:\Documents and Settings\Peter Thejll\My Documents\WORK\effective_solar_radiation'
data=get_data(file)
print,'reading effective_solar_radiation'
SV=reform(data(*))
total_forcing=total_GHG_forcing+SV*(1.0-0.3)/4.
; just the volcanic forcing
file='C:\Documents and Settings\Peter Thejll\My Documents\WORK\ROBERTSON_VOLCANICnoheader.dat'
data=get_data(file)
Volcanicforcing=reform(data(1,*))
; justthe SOlar irradiance
file='C:\Documents and Settings\Peter Thejll\My Documents\WORK\ROBERTSON_IRRADIANCEnoheader.dat'
data=get_data(file)
SOlarirradiance=reform(data(1,*))
; get the global mean surface albedo
file='C:\Documents and Settings\Peter Thejll\My Documents\WORK\Global_mean_albedo.dat'
data=get_data(file)
albedo=reform(data(1,*))
l=size(albedo,/dimensions)
albedo=rebin(albedo,l(0)/12)
!P.MULTI=[0,1,6]
plot,year,CO2,xtitle='Year',ytitle='CO!d2!n (ppm)',ystyle=1,charsize=1.5,linestyle=1
plot,year,CH4,xtitle='Year',ytitle='CH!d4!n (ppb)' ,ystyle=1,charsize=1.5,linestyle=2
plot,year,N2O,xtitle='Year',ytitle='N!d2!nO (ppb)' ,ystyle=1,charsize=1.5,linestyle=3
plot,year,F11+F12,xtitle='Year',ytitle='CFCs (ppb)' ,ystyle=1,charsize=1.5,linestyle=4
plot,year,total_GHG_forcing,thick=8,xtitle='Year',ytitle='GHG forcing (W/m!u2!n)',ystyle=1,charsize=1.5
oplot,year,total_GHG_forcing,thick=4,color=0
oplot,year,F_CO2,linestyle=1
oplot,year,F_CH4,linestyle=2
oplot,year,F_N2O,linestyle=3
oplot,year,CFCFORC,linestyle=4
plot,year,total_forcing,thick=8,xtitle='Year',ytitle='Forcing (W/m!u2!n)',ystyle=1,charsize=1.5
; save the Forcing
openw,12,'C:\Documents and Settings\Peter Thejll\My Documents\WORK\GLIMPSE_forcings_global_mean.dat'
printf,12,'year   total_forcing  Sun_irr  Albedo   V  total_GHG_forcing'


for i=0,n_elements(SV)-1,1 do begin
print,format='(i4,7(1x,f12.3))',year(i),total_forcing(i),solarirradiance(i),albedo(i),volcanicforcing(i),total_GHG_forcing(i)
printf,12,format='(i4,7(1x,f12.3))',year(i),total_forcing(i),solarirradiance(i),albedo(i),volcanicforcing(i),total_GHG_forcing(i)
endfor
close,12
;-----------------
file='C:\Documents and Settings\Peter Thejll\My Documents\WORK\GLIMPSE_forcings_global_mean.dat'
data=get_data(file)
yr=reform(data(0,*))
total=reform(data(1,*))
solar=reform(data(2,*))
albedo=reform(data(3,*))
volcanic=reform(data(4,*))
ghg=reform(data(5,*))
!P.MULTI=[0,1,5]
plot,yr,total,xtitle='Year',ytitle='Total forcing [W/m2]',ystyle=1,charsize=2
plot,yr,solar,xtitle='Year',ytitle='Solar irradiance [W/m2]',ystyle=1,charsize=2
plot,yr,albedo,xtitle='Year',ytitle='Albedo',ystyle=1,charsize=2
plot,yr,volcanic,xtitle='Year',ytitle='Volcanic forcing [W/m2]',ystyle=1,charsize=2
plot,yr,ghg,xtitle='Year',ytitle='GHG forcing [W/m2]',ystyle=1,charsize=2
end
