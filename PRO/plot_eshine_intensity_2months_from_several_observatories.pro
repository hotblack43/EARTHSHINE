PRO alsoplotCoverageperday
str="cat deltas.dat | sort | uniq | sed 's/\./ /g' | awk '{print $1}' | sort | uniq -c > counted.dat "
spawn,str
data=get_data('counted.dat')
counts=reform(data(0,*))
day=reform(data(1,*))
curve=counts/96.*0.12
x=day(1:n_elements(curve)-2)
y=curve(1:n_elements(curve)-2)
oplot,x-min(x),y,psym=10
return
end

PRO returnNnames,N,names
 obsnames= ['lund', 'tug', 'dmi', 'kpno', 'ctio', 'eso', 'lick', $
 'mmto', 'cfht', 'mlo', 'lapalma', 'mso', 'sso', 'aao', 'mcdonald',$
 'lco', 'mtbigelow', 'dao', 'spm', 'tona', 'Palomar', 'mdm', $
 'NOV', 'bmo', 'BAO', 'keck', 'ekar', 'apo', 'lowell', 'vbo', $
 'flwo', 'oro', 'lna', 'saao', 'casleo', 'bosque', 'rozhen', $
 'irtf', 'bgsuo', 'ca', 'holi', 'lmo', 'fmo', 'whitin']
; fixednames=['mlo','lapalma','Palomar']
 NN=n_elements(obsnames)
 idx=fix(randomu(seed,n)*NN)
 ;idx=fix(randomu(seed,n-n_elements(fixednames))*NN)
 names=obsnames(idx)
 ;names=[fixednames,obsnames(idx)]
 return
 end
 
 PRO getjustheobservablemoments,jd,eshine,jduse,eshineuse,obsname
 ic=0
 for i=0,n_elements(jd)-1,1 do begin
     xJD=jd(i)
     MOONPOS, xJD, ramoon, decmoon
     eq2hor, ramoon, decmoon, xJD, altmoon, azmoon,  OBSNAME=obsname,refract_=0
     SUNPOS, xJD, rasun, decsun
     eq2hor, rasun, decsun, xJD, altsun, azsun,  OBSNAME=obsname,refract_=0
     if (altmoon gt 0 and altsun lt 0) then begin
         ; Moon is observable
         if (ic eq 0) then begin
             jduse=xJD
             eshineuse=eshine(i)
             endif else begin
             jduse=[jduse,xJD]
             eshineuse=[eshineuse,eshine(i)]
             endelse
         ic=ic+1
         endif
     endfor
 return
 end
 
 !P.MULTI=[0,1,2]
 !P.CHARSIZE=1.6
 !P.thick=2
 !x.thick=2
 !y.thick=2
 N=7
 best_july=-1e22
 best_january=-1e22
 for iter=1,5000,1 do begin
 set_plot,'ps'
device,/color
device,xsize=18,ysize=24.5,yoffset=2
 returnNnames,N,obsnames
 print,'Using: ',obsnames
 colname=['red','blue','orange','yellow','green','Goldenrod','Pink']
 months=['january','july']
 for imonth=1,2,1 do begin
     openw,33,'deltas.dat'
     month=months(imonth-1)
     for iobs=0,n_elements(obsnames)-1,1 do begin
         data=get_data(strcompress('earthshine_intensity_'+month+'.dat',/remove_all))
         kdx=indgen(4000)+0
         jd=reform(data(0,kdx))
         Sshine=reform(data(1,kdx))
         eshine=reform(data(2,kdx))
         ph_M=reform(data(3,kdx))
         ph_E=reform(data(4,kdx))
         getjustheobservablemoments,jd,eshine,jduse,eshineuse,obsnames(iobs)
         if (iobs eq 0) then plot,yrange=[0,0.12],title=month,xstyle=3,jd-min(jd),eshine,xtitle='days',ytitle='earthshine intensity [W/m!u2!n]'
         offset=0.000
         oplot,jduse-min(jd),eshineuse+iobs*offset,color=fsc_color(colname(iobs)),psym=7
         if (imonth eq 1) then xyouts,1,0.11-iobs*0.01,obsnames(iobs)+' : '+colname(iobs)
         if (imonth eq 2) then xyouts,1,0.11-iobs*0.01,obsnames(iobs)+' : '+colname(iobs)
         delta=jduse-shift(jduse,1)
         delta=delta(1:n_elements(delta)-1)
         idx=where(delta gt 0.011)
         if (idx(9) ne -1) then begin
             print,format='(a,a,1x,f5.2,a)','Observable from ',obsnames(iobs),100.-total(delta(idx))/(max(jd)-min(jd))*100.,' % of the time'
             endif
         for kl=0,n_elements(jduse)-1,1 do printf,33,format='(f15.7)',jduse(kl)
         endfor
     close,33
     jduse=get_data('deltas.dat')
     jduse=jduse(sort(jduse))
     jduse=jduse(uniq(jduse))
     delta=jduse-shift(jduse,1)
     delta=delta(1:n_elements(delta)-1)
     idx=where(delta gt 0.011)
     if (idx(9) ne -1) then begin
         print,format='(a,1x,f5.2,a)','In total, Observable ',100.-total(delta(idx))/(max(jd)-min(jd))*100.,' % of the time'
         xyouts,25,0.08,string(100.-total(delta(idx))/(max(jd)-min(jd))*100.,format='(f4.1)')+' %.'
         print,format='(a,1x,a,1x,f5.2,7(1x,a))','Coverage: ',month,100.-total(delta(idx))/(max(jd)-min(jd))*100.,obsnames
         alsoplotCoverageperday
         endif
 device,/close
 globcov=100.-total(delta(idx))/(max(jd)-min(jd))*100.
 if (imonth eq 1 and globcov gt best_january) then begin
	spawn,'mv idl.ps '+strcompress('best_januray_'+string(n)+'_observatories.ps',/remove_all)
 	best_january=globcov
 endif
 if (imonth eq 2 and globcov gt best_july) then begin
	spawn,'mv idl.ps '+strcompress('best_july_'+string(n)+'_observatories.ps',/remove_all)
 	best_july=globcov
 endif
     endfor	; end of imonth loop
 print,'best: ',best_january,best_july
 endfor	; end of iter loop
 end
