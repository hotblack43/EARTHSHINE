PRO extract_photometry,im,x1,y1,x2,y2,phot1,phot2
 phot1=im(x1,y1)
 phot2=im(x2,y2)
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
 
 
 ;===============================================================
 ; Will align images and extract photometric information from 
 ; designated pixels
 ;===============================================================
 ; October 10 2010, Peter Thejll
 ;===============================================================
 x1=135
 y1=180
 x2=368
 y2=305
 openw,5,'photometry.dat'
 files=file_search('align_stacked_CoAdd-*.fits',count=n)
 im0=readfits(files(0),/NOSCALE,h)
 get_date,h,time
 get_EXPOSURE,h,exptime
 extract_photometry,im0,x1,y1,x2,y2,phot1,phot2
 fmt='(a,f15.6,1x,f8.4,1x,i5,1x,i5,1x,f12.6)'
 fmt2='(f15.6,1x,f8.4,1x,i5,1x,i5,1x,f12.6)'
 print,format=fmt,'JD, EXP, phot1,phot2,ph1/ph2 = ',time,exptime,phot1,phot2,phot1/phot2
     printf,5,format=fmt2,time,exptime,phot1,phot2,phot1/phot2
 for i=1,n-1,1 do begin
     im=readfits(files(i),/NOSCALE,h)
     get_date,h,time
     get_EXPOSURE,h,exptime
     shifts=alignoffset(im,im0,Cor)
     im=shift_sub(im,-shifts(0),-shifts(1))
     extract_photometry,im,x1,y1,x2,y2,phot1,phot2
     print,format=fmt,'JD, EXP, phot1,phot2,ph1/ph2 = ',time,exptime,phot1,phot2,phot1/phot2
     printf,5,format=fmt2,time,exptime,phot1,phot2,phot1/phot2
     contour,im,/isotropic
     endfor
close,5
data=get_data('photometry.dat')
t=reform(data(0,*))
ratio=reform(data(4,*))
plot,t-min(t),ratio,xtitle='JD since start',ytitle='Crisium/Grimaldi',charsize=1.2,psym=7,xstyle=3,ystyle=3
 end
