PRO make_radius,im,radius
 l=size(im,/dimensions)
 radius=fltarr(l(0),l(1))
 for i=0,l(0)/2.-1,1 do begin
     for j=0,l(1)/2.-1,1 do begin
         radius(i,j)=sqrt(i^2 +j^2)
         endfor
     endfor
 return
 end
 
common holder,iflag,data
iflag=0
 ; BBSO mode example
 ;ims=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455473/BBSO-33Frame-LO-r1-1.fits')
 ; CoADD mode example
 ims=readfits('/data/pth/DATA/ANDOR/EarthshineData/Data20100903/Moon-CoAdd-9ms-100frame-R12.fits')
 l=size(ims,/dimensions) & n= l(2)
 openw,11,'focus.dat'
 
 for i=0,n-1,1 do begin
     im=ims(*,*,i)
     if (i eq 0) then begin
         make_radius,im,radius
         endif
     z=ffT(im,-1,/double)
     zz=float(z*conj(z))
     idx=where(radius ge 2 and radius le 5)
     jdx=where(radius ge 10 and radius le 20)
     focus=total(zz(jdx))/total(zz(idx))
     focus2=total(im^2)/(total(im)^2)
     shannon_entropy,im,focus3
     print,i,focus,focus2,focus3
     printf,11,i,focus,focus2,focus3
     endfor
 close,11
 data=get_data('focus.dat')
 imagenum=reform(data(0,*))
 focus=reform(data(1,*))
 focus2=reform(data(2,*))
 focus3=reform(data(3,*))
 !P.MULTI=[0,2,2]
 !P.CHARSIZE=1.2
 plot,imagenum,focus/mean(focus)*100.,psym=-7,ytitle='Focus from spectral slope',xtitle='Image number',xstyle=1,ystyle=1
 plot,imagenum,focus2/mean(focus2)*100.,psym=-7,ytitle='Focus from SSQ/SQS in pct of mean',xtitle='Image number',xstyle=1,ystyle=1
 plot,imagenum,focus3/mean(focus3)*100.,psym=-7,ytitle='Focus from Shannon in pct of mean',xtitle='Image number',xstyle=1,ystyle=1
 plot,focus/mean(focus)*100.,focus2/mean(focus2)*100.,psym=7,xstyle=1,ystyle=1,xtitle='Focus from sp. slope in pct of mean',ytitle='Focus from SSQ/SQS in pct of mean'
 plot,focus/mean(focus)*100.,focus3/mean(focus3)*100.,psym=7,xstyle=1,ystyle=1,xtitle='Focus from sp. slope in pct of mean',ytitle='Focus from Shannon in pct of mean'
 !P.MULTI=[0,2,4]
; Method 1
 bestid=where(focus eq max(focus))
 worstid=where(focus eq min(focus))
 print,'Slopes: Best,Worst idx:',bestid,worstid
 contour,ims(*,*,bestid),/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101,title=strcompress('Best focus from slopes. No: '+string(bestid))
 contour,ims(*,*,worstid),/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101,title=strcompress('Worst focus from slopes. No: '+string(worstid))
; subimages
x0=379
y0=273
w=10
 contour,ims(x0-w:x0+w,y0-w:y0+w,bestid),/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101,title=strcompress('Best focus from slopes. No: '+string(bestid))
 contour,ims(x0-w:x0+w,y0-w:y0+w,worstid),/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101,title=strcompress('Worst focus from slopes. No: '+string(worstid))
; Method 2
 bestid=where(focus2 eq max(focus2))
 worstid=where(focus2 eq min(focus2))
 contour,ims(*,*,bestid),/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101,title=strcompress('Best focus from SSQ/SQS. No: '+string(bestid))
 contour,ims(*,*,worstid),/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101,title=strcompress('Worst focus from SSQ/SQS. No: '+string(worstid))
; subimages
x0=379
y0=273
w=10
 contour,ims(x0-w:x0+w,y0-w:y0+w,bestid),/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101,title=strcompress('Best focus from SSQ/SQS. No: '+string(bestid))
 contour,ims(x0-w:x0+w,y0-w:y0+w,worstid),/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101,title=strcompress('Worst focus from SSQ/SQS. No: '+string(worstid))
 print,'SSQ/SQS: Best,Worst idx:',bestid,worstid
; Method 3
 bestid=where(focus3 eq max(focus3))
 worstid=where(focus3 eq min(focus3))
 contour,ims(*,*,bestid),/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101,title=strcompress('Best focus from Shannon. No: '+string(bestid))
 contour,ims(*,*,worstid),/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101,title=strcompress('Worst focus from Shannon. No: '+string(worstid))
; subimages
x0=379
y0=273
w=10
 contour,ims(x0-w:x0+w,y0-w:y0+w,bestid),/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101,title=strcompress('Best focus from Shannon. No: '+string(bestid))
 contour,ims(x0-w:x0+w,y0-w:y0+w,worstid),/isotropic,xstyle=1,ystyle=1,/cell_fill,nlevels=101,title=strcompress('Worst focus from Shannon. No: '+string(worstid))
 print,'Shannon: Best,Worst idx:',bestid,worstid
 end
