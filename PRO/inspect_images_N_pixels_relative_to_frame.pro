PRO extract_photometry,im,N,x1,y1,x2,y2,phot1,phot2
common stuff,ref,skyslope
 phot1=mean(im(x1-N:x1+N,y1-N:y1+N),/double)
 phot2=mean(im(x2-N:x2+N,y2-N:y2+N),/double)
; reference
 ref=mean(im(40:130,40:130),/double)
 phot1=phot1-ref
 phot2=phot2-ref
 skyslope=mean(im(125:130,125:130))-mean(im(5:10,5:10))
 skyslope=skyslope/ref
 print,'ref=',ref
 print,'skyslope=',skyslope
 return
 end
 
 PRO get_date,h,time
 ;DATE             file creation date (YYYY-MM-DDThh:mm:ss)
 ;strmid(h(ipos),11,19)
 ;2010-09-23T09:43:02
 ipos=where(strpos(h,'DATE') ne -1)
 date_str=strmid(h(ipos),11,19)
 yy=fix(strmid(date_str,0,4))
 mm=fix(strmid(date_str,5,2))
 dd=fix(strmid(date_str,8,2))
 hh=fix(strmid(date_str,11,2))
 mi=fix(strmid(date_str,14,2))
 se=fix(strmid(date_str,17,2))
 time=double(julday(mm,dd,yy,hh,mi,se))
 return
 end
 
 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 
 ;
 ;===============================================================
 ; Will align images and extract photometric information from 
 ; designated pixels. In each 'patch' there are N pixels
 ;===============================================================
 ; October 10 2010, Peter Thejll
 ;===============================================================
 common stuff,ref,skyslope
 ;===============================================================
 x1=172
 y1=212
 x2=368
 y2=276
 path='/media/LaCie/ASTRO/ANDOR/'
 files=file_search(path+'align_stacked_CoAdd*.fits',count=nims)
 openw,67,'Files.dat' & for k=0,nims-1,1 do printf,67,format='(i3,1x,a)',k,files(k) & close,67
 im0=readfits(files(0),/NOSCALE,h)
 openw,5,'photometry.dat'
 for N=0,9,1 do begin	; this is the 'half width of the window around the central pixel
     get_date,h,time
     get_EXPOSURE,h,exptime
     extract_photometry,im0,N,x1,y1,x2,y2,phot1,phot2
     fmt='(a,i3,1x,f15.6,1x,f8.4,1x,f9.6,1x,f12.6,1x,f14.8,1x,i2,(1x,f8.5))'
     fmt2='(i3,1x,f15.6,1x,f8.4,1x,f9.6,1x,f12.6,1x,f14.8,1x,i2,1x,2(f8.5))'
     labs='#, JD, EXP, phot1,phot2,ph1/ph2,N = '
         print,format=fmt,labs,0,time,exptime,phot1,phot2,phot1/phot2,N,ref,skyslope
         printf,5,format=fmt2,0,time,exptime,phot1,phot2,phot1/phot2,N,ref,skyslope
     for i=1,nims-1,1 do begin
         im=readfits(files(i),/NOSCALE,h)
         get_date,h,time
         get_EXPOSURE,h,exptime
         shifts=alignoffset(im,im0,Cor)
         im=shift_sub(im,-shifts(0),-shifts(1))
         extract_photometry,im,N,x1,y1,x2,y2,phot1,phot2
         print,format=fmt,labs,i,time,exptime,phot1,phot2,phot1/phot2,N,ref,skyslope
         printf,5,format=fmt2,i,time,exptime,phot1,phot2,phot1/phot2,N,ref,skyslope
         contour,im,/isotropic
         endfor; end of i loop
     endfor	; end of loop over N
 close,5
 set_plot,'ps'
 data=get_data('photometry.dat')
 framenum=reform(data(0,*))
 t=reform(data(1,*))
 ratio=reform(data(5,*))
 n=reform(data(6,*))
 ref=reform(data(7,*))
 skyslope=reform(data(8,*))
 exp_string='100 images aligned and averaged, dark-subtracted, NO scattered light remved'
 plot,t-min(t),ratio,xtitle='JD since start',ytitle='Crisium/Grimaldi',charsize=1.2,psym=7,xstyle=3,ystyle=3,title=exp_string
;
 plot,t-min(t),ref,xtitle='JD since start',ytitle='Reference patch mean',charsize=1.2,psym=7,xstyle=3,ystyle=3,title='Sky patch reference - 40:130x40:130'
 plot,t-min(t),skyslope,xtitle='JD since start',ytitle='Slope of sky gradient',charsize=1.2,psym=7,xstyle=3,ystyle=3,title='Slope between 2 sky patches.'
;
 nu=n(sort(n))
 uniq_n=nu(uniq(nu))
 openw,7,'Nvsmeans.dat'
 for k=0,n_elements(uniq_n)-1,1 do begin
     idx=where(n eq uniq_n(k))
     print,'S.D. in pct for frames with N=',uniq_n(k),stddev(ratio(idx))/mean(ratio(idx))*100.0,stddev(ratio(idx))/mean(ratio(idx))*100.0/sqrt(n_elements(idx)-1.)
     printf,7,uniq_n(k),stddev(ratio(idx))/mean(ratio(idx))*100.0
     endfor	; end k loop
 close,7
 ;
 data=get_data('Nvsmeans.dat')
 n=reform(data(0,*))
 pct=reform(data(1,*))
 plot,n,pct,xstyle=3,ystyle=3,charsize=1.2,xtitle='Window half width',ytitle='S.D. in pct',title='Convergence of photometric ratio with window size',psym=-7
 device,/close
 end
