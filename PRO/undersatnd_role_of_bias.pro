PRO extract_photometry,im,N,x1,y1,x2,y2,phot1,phot2
 phot1=mean(im(x1-N:x1+N,y1-N:y1+N),/double)
 phot2=mean(im(x2-N:x2+N,y2-N:y2+N),/double)
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
 ; Looks at the role that a bias has on the error of the photometric ratio
 ; within one image.
 ;===============================================================
 ; October 10 2010, Peter Thejll
 ;===============================================================
     fmt='(a,i3,3(1x,f15.6),1x,i2)'
     fmt2='(i3,3(1x,f15.6),1x,i2)'
     labs='#, JD, EXP, phot1,phot2,ph1/ph2,N = '
 IM=readfits('align_stacked_CoAdd-100Frame-LO-r15.fits',/NOSCALE,h) 
 x1=172
 y1=212
 x2=368
 y2=276
 N=9
 openw,5,'role_of_bias.dat'
 for bias=-3,3,1 do begin
     extract_photometry,IM-bias,N,x1,y1,x2,y2,phot1,phot2
     print,format=fmt,labs,bias,phot1,phot2,phot1/phot2,N
     printf,5,format=fmt2,bias,phot1,phot2,phot1/phot2,N
 endfor
 close,5
 data=get_data('role_of_bias.dat')
 bias=reform(data(0,*))
 ratio=reform(data(3,*))
 print,'SD of ratio',stddev(ratio)/mean(ratio)*100.,' %'
 plot,bias,ratio,psym=7,xtitle='Bias',ytitle='Ratio',title='Role of various bias on extracted photometric ratio. N=9',charsize=1.2,xstyle=3,ystyle=3
 end
