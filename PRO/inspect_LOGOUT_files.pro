PRO correctsodubleslashes,str
; will remove double /'s from the filename
idx=strpos(str,'//')
if (idx(0) eq -1) then stop
str=strmid(str,0,idx)+strmid(str,idx+1)
str=strcompress(str,/remove_all)
return
end

 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end

PRO getnumbersandnames,name,data,names
openr,89,name
ic=0
while not eof(89) do begin
x=fltarr(7)
str=''
readf,89,x,str
if (ic eq 0) then data=x
if (ic gt 0) then data=[[data],[x]]
if (ic eq 0) then names=str
if (ic gt 0) then names=[names,str]
ic=ic+1
endwhile
close,89
return
end

!P.MULTI=[0,2,3]
!P.CHARSIZE=1.6
filters=['B','VE1','V','VE2','IRCUT']
for ifilter=0,4,1 do begin
filter=filters(ifilter)
name=strcompress('logOUT_'+filter+'.dat',/remove_all)
;data=get_data(name)
getnumbersandnames,name,data,names
jd=reform(data(0,*))
az=reform(data(1,*))
ph=reform(data(2,*))
am=reform(data(3,*))
counts=reform(data(4,*))
exptime=reform(data(5,*))
totflux=counts/(exptime+2.5e-4)
magnitudes=13.-2.5*alog10(totflux)
radius=reform(data(6,*))
plot,title=filters(ifilter),ystyle=3,psym=7,xrange=[-180,180],yrange=[-5,-15],ph,magnitudes,xtitle='SEM phase angle',ytitle='Mags'
magoffset=[-7.2,-10.1,-8.3,-8.6,-10.0]
mag=magoffset(ifilter)-(0.036*abs(ph)+4e-9*ph^4)
oplot,ph,mag,psym=1,color=fsc_color('red')
; print th eratio between observed fluxes and the Allen model
openw,66,strcompress('ratio_obs_to_model_totflux_'+string(filters(ifilter))+'.dat',/remove_all)
for ikd=0,n_elements(ph)-1,1 do begin
str=names(ikd)
;correctsodubleslashes,str
names(ikd)=strcompress(str,/remove_all)
im=readfits(names(ikd),header,/silent)
print,names(ikd)
get_time,header,JD
print,format='(f15.7,1x,e20.10,1x,f5.3,1x,f9.3,1x,a)',JD,totflux(ikd),am(ikd),magnitudes(ikd)/mag(ikd),names(ikd)
printf,66,format='(f15.7,1x,e20.10,1x,f5.3,1x,f9.3,1x,a)',JD,totflux(ikd),am(ikd),magnitudes(ikd)/mag(ikd),names(ikd)
endfor
close,66
; Allen table 143 instead
; get the Allen table
; data=get_data('lunar_irradiance_Allen.dat')
; ALLENph=reform(data(0,*))-180
; ALLENfl=16.-2.5*alog10(reform(data(1,*)))
;oplot,ALLENph,ALLENfl,psym=4,color=fsc_color('blue')
endfor
end
