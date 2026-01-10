PRO get_temperature,header,temperature
 idx=where(strpos(header, 'UNSTTEMP') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 temperature=float(strmid(str,16,15))
 return
 end
 
 PRO medianfilterthestacks,im
 dummy=dblarr(512,512)
 for i=0,511,1 do begin
     for j=0,511,1 do begin
         line=im(i,j,*)
         dummy(i,j)=median(line)
         endfor
     endfor
 im=dummy
 return
 end
 
 
 
 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 ;=====================================
 fmt='(f6.4,1x,f22.1,1x,f10.1)'
 openw,33,'fluxes.dat'
 bias=readfits('superbias.fits',/silent)
 file='LAML_flats_tolookat.txt'
 openr,1,file
 str=''
 while (not eof(1)) do begin
     readf,1,str
     print,str
     im=readfits(str,h,/silent)
     get_EXPOSURE,h,exptime
     get_temperature,h,temperature
     if (max(im) lt 10000 and temperature eq -999) then begin
         medianfilterthestacks,im
         offset=0.0;1.95
         flux=total(im-bias,/double)/(exptime(0)+offset)
         printf,33,format=fmt,exptime,flux,median(im-bias)
         print,format=fmt,exptime,flux,max(im-bias)
         tvscl,hist_equal((im-bias)/exptime(0)+offset)
         endif
     endwhile
 close,1
 close,33
 data=get_data('fluxes.dat')
 exptime=reform(data(0,*))
 flux=reform(data(1,*))
 !P.CHARSIZE=1.7
 !P.THICK=3
 !X.thick=2
 !y.thick=2
 plot,xstyle=3,ystyle=3,exptime,flux,psym=7
 end
