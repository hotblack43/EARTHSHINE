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

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 exptime=exptime(0)
 return
 end


openw,4,'plotme.dat'
file='CLEM.profiles_fitted_results.txt'
fname='_IRCUT_'
fname='_VE2_'
spawn,"grep "+fname+" "+file+" | grep -v CUBES | awk '{print $5}' > pedestal"
spawn,"grep "+fname+" "+file+" | grep -v CUBES | awk '{print $8}' > names"
openr,1,'pedestal'
openr,2,'names'
obsname='mlo'
observatory,obsname,obs_struct
while not eof(2) do begin
texp=-911
ped=1.0d0
str=''
readf,1,ped
readf,2,str
im=readfits(strcompress('/data/pth/CUBES/'+str,/remove_all),h,/sil)
get_EXPOSURE,h,texp
get_time,h,JD
         moonpos, JD, RAmoon, DECmoon
         eq2hor, ramoon, decmoon, jd, alt_moon, az, ha,  OBSNAME=obsname
         am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, obs_struct.latitude*!dtor, obs_struct.longitude*!dtor)
print,ped,texp,am
printf,4,ped,texp,am
endwhile
close,2
close,1
close,4
data=get_data('plotme.dat')
ped=reform(data(0,*))
texp=reform(data(1,*))
am=reform(data(2,*))
!P.MULTI=[0,1,2]
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
plot,texp,ped,psym=7,xtitle='Exposure time [s]',ytitle='Pedestal'
plot_io,yrange=[1,10],am,ped,psym=7,xtitle='Airmass',ytitle='Pedestal'
end
