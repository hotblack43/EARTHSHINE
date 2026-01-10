PRO gofetchFMdata,jdin,FMalbedo,d_FMalbedo,iflag
; extract albedo info from the FM datafile
 if (file_exist('array') eq 0) then begin
     clemfile='CLEM.profiles_fitted_results_SEP_2014_semiempirical.txt'
     str="awk '{print $1,$2,$3} ' "+clemfile+" > array"
     spawn,str
     endif
 array=get_data('array')
 idx=where(array(0,*) eq jdin)
 iflag=314
 FMalbedo=-911
 d_FMalbedo=-911
 if (idx(0) ne -1) then begin
     iflag=0
     FMalbedo=array(1,idx)
     d_FMalbedo=array(2,idx)
     endif
 return
 end
 
 close,/all
 spawn,'rm array'
 data=get_data('BBSO_lin_log_DCR_albedos.dat')
 jd=reform(data(0,*))
 dcr=reform(data(1,*))
 d_dcr=reform(data(2,*))
 lin=reform(data(3,*))
 d_lin=reform(data(4,*))
 log=reform(data(5,*))
 d_log=reform(data(6,*))
 ph=reform(data(7,*))
 k=reform(data(8,*))
 am=reform(data(9,*))
 pct=(lin-log)/log*100.
 ;
 nJD=n_elements(jd)
 ic=0
 openw,44,'BBSO_FM.dat'
 for iJD=0,nJD-1,1 do begin
     gofetchFMdata,jd(iJD),FMalbedo,d_FMalbedo,iflag
     if (iflag eq 0) then printf,44,format='(f15.7,1x,f6.1,5(1x,f9.5))',jd(ijd),ph(iJD),log(iJD),d_log(iJD),FMalbedo,d_FMalbedo,am(ijd)
     ic=ic+1
     endfor
 close,44
 print,'Now plot data in BBSO_FM.dat'
 end
