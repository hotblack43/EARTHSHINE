 
 
 !P.CHARSIZE=1.8
 filternames=['B','V','VE1','VE2','IRCUT']
 cols=['blue','green','yellow','orange','red']
 starnumbers=[17,4,1,44,30,27,22]
 nstars=n_elements(starnumbers)
 !P.MULTI=[0,1,5]
 for istar=0,nstars-1,1 do begin
     dat=get_data(strcompress('Star_'+string(starnumbers(istar))+'_photometry.dat',/remove_all))
     jd=reform(dat(0,*))
     mag=reform(dat(1,*))
     magerr=reform(dat(2,*))
     airmass=reform(dat(3,*))
     ra=reform(dat(4,*))
     dec=reform(dat(5,*))
     filter=reform(dat(6,*))
     ;------------------------------
     liste=filter(sort(filter))
     uniqfilters=liste(uniq(liste))
     nu=n_elements(uniqfilters)
     for ifilter=0,nu-1,1 do begin;nu-1,1 do begin
         ;for ifilter=0,nu-1,1 do begin
         idx=where(filter eq uniqfilters(ifilter))
         if (n_elements(idx) ge 20) then begin
;            plot,airmass(idx),mag(idx),psym=7,xstyle=3,ystyle=3
;            oplot,airmass(idx),mag(idx),psym=7,color=fsc_color(cols(ifilter))
histo,mag(idx)-0.1*airmass(idx),-8,-3,0.01,/abs,$
title=cols(ifilter)
             endif
         endfor
     endfor
 end
