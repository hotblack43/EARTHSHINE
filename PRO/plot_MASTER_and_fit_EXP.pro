PRO getuniqueintegerJD,jd,nunique,intJDS
intJDs=long(jd)
intJDs=intJDS(sort(intJDs))
intJDS=intJDs(uniq(intJDs))
nunique=n_elements(intJDs)
return
end

 PRO get_airmass_fromJD,JD,amarr
 amarr=[]
 lat=ten([19,32.4])
 lon=ten([155,34.4])
 for k=0,n_elements(jd)-1,1 do begin
 ; get the airmass
 moonpos, JD(k), RAmoon, DECmoon
 am = airmass(JD(k), RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
 am=am(0)
 amarr=[amarr,am]
 endfor
 return
 end

PRO getphasefromJD,JD,phasearr
 phasearr=[]
 for k=0,n_elements(jd)-1,1 do begin
	 MOONPHASE,jd(k),phase_angle_M,alt_moon,alt_sun,obsname
	 phase=phase_angle_M
	 phasearr=[phasearr,phase]
 endfor
 return
 end

PRO goplot,jd,albedo,dAlbedo,filt,filterchoice,plottype,colname,xstr,ystr
common ranges,xra,yra,titstr
xra=[1,10];[min(jd),max(jd)]
yra=[0.2,0.45];[min(albedo),max(albedo)]
idx=where(filt eq filterchoice)
if (idx(0) ne -1) then begin
if (plottype eq 0) then begin
plot,jd(idx),albedo(idx),psym=-1,xrange=xra,yrange=yra,xtitle=xstr,ytitle=ystr,title='LRO'+titstr
oploterr,jd(idx),albedo(idx),dalbedo(idx)
endif else begin
oplot,jd(idx),albedo(idx),psym=-1,color=fsc_color(colname)
oploterr,jd(idx),albedo(idx),dalbedo(idx)
endelse
endif
return
end

FUNCTION interquartilrange,x_in
x=x_in
n=n_elements(x)
x=x(sort(x))
q1=x(n/3.)
q2=x(n/2.)
q3=x(n*2./3.)
value=q3-q1
return,value
end

PRO makehisto2,x,xstr
IQR=interquartilrange(x)
binsize=2.*IQR*N_elements(x)^(-1./3.)
histo,/abs,x,0,0.9,0.09/21.,xtitle=xstr,title='All albedo uncertainties'
med=median(x)
xyouts,/data,0.4,8,'median = '+string(med,format='(f8.5)')
return
end

PRO makehisto,x,xstr
IQR=interquartilrange(x)
binsize=2.*IQR*N_elements(x)^(-1./3.)
histo,/abs,x,0,0.04,0.04/21.,xtitle=xstr,title='All albedo uncertainties'
med=median(x)
xyouts,/data,0.02,8,'median = '+string(med,format='(f8.5)')
return
end



common ranges,xra,yra,titstr
!P.charsize=2
!P.thick=3
!P.charthick=2
;2456104.8120040     B   31    0.3719  0.005681
file='MASTER_outputlist_from_bagging.txt'
str="awk '{print $1,$3,$4,$5,$6}' "+file+" > data.dat"
spawn,str
str="awk '{print $2}' "+file+" > fileter_data.dat"
spawn,str
data=get_data('data.dat')
jd=reform(data(0,*))
getphasefromJD,JD,phasearr
get_airmass_fromJD,JD,amarr
N=reform(data(1,*))
Albedo=reform(data(2,*))
dAlbedo=reform(data(3,*))
rmse=reform(data(4,*))
openr,33,'fileter_data.dat'
str=''
filt=[]
while not eof(33) do begin
readf,33,str
filt=[filt,str]
endwhile
close,33
; loop over all sets of JDs to get one plotper night.
getuniqueintegerJD,jd,nunique,uniqueJDs
!P.MULTI=[0,1,4]
for iuniqueJD=0,nunique-1,1 do begin
titstr=string(uniqueJDs(iuniqueJD))
ldx=where(long(jd) eq uniqueJDs(iuniqueJD))
if (ldx(0) ne -1) then begin
;
goplot,amarr(ldx),albedo(ldx),dAlbedo(ldx),filt(ldx),'B',0,'anything','Airmass','Albedo'
goplot,amarr(ldx),albedo(ldx),dAlbedo(ldx),filt(ldx),'B',1,'blue','Airmass','Albedo'
goplot,amarr(ldx),albedo(ldx),dAlbedo(ldx),filt(ldx),'V',1,'green','Airmass','Albedo'
goplot,amarr(ldx),albedo(ldx),dAlbedo(ldx),filt(ldx),'VE1',1,'orange','Airmass','Albedo'
goplot,amarr(ldx),albedo(ldx),dAlbedo(ldx),filt(ldx),'IRCUT',1,'yellow','Airmass','Albedo'
goplot,amarr(ldx),albedo(ldx),dAlbedo(ldx),filt(ldx),'VE2',1,'red','Airmass','Albedo'

openw,38,strcompress(titstr+'_xy.dat',/remove_all)
for k=0,n_elements(ldx)-1,1 do begin
	printf,38,amarr(ldx(k)),albedo(ldx(k))
endfor
close,38
;
;makehisto,dAlbedo(ldx),'!7D!3 albedo (LRO)'
;makehisto2,rmse(ldx),'RMSE (LRO)'
endif
endfor
end
