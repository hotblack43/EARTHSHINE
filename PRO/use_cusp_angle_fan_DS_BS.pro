 PRO use_cusp_angle_fan_DS_BS,actioninidcator,im,x0,y0,radius,rad,line,err_line,imethod,w1,w2,w3,w4
 common thetaflags,iflag_theta,radii,theta,xline,yline
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl,paramname
 common cuspanglestuff,iflagcuspangle,cangle
 common vizualisation,ifviz
     if_want_bootstrap=1
 l=size(im,/dimensions)
 ;
 ;if(iflag_theta ne 314) then begin
 radii=fltarr(l)
 theta=fltarr(l)
 xline=intarr(l)
 yline=intarr(l)
 print,'Here x0,y0,radius:',x0,y0,radius
 for icol=0,l(0)-1,1 do begin
     for irow=0,l(1)-1,1 do begin
         xline(icol,irow)=icol
         yline(icol,irow)=irow
         radii(icol,irow)=sqrt((icol-x0)^2+(irow-y0)^2)
         theta(icol,irow)=atan((irow-y0)/(icol-x0))/!dtor
         endfor
     endfor
 idx=where(xline le x0)
 theta(idx)=180+theta(idx)
 idx=where(yline le y0 and xline ge x0)
 theta(idx)=360+theta(idx)
;findcuspanglefromimage,im,x0,y0,radius(0),cangle
 print,'Found cusp angle: ',cangle
 left=avg(im(0:x0,*))
 right=avg(im(x0:511,*))
 print,'left,right:',left,right
 ipntr=1
 if (left lt right) then ipntr=-1
 print,'ipntr: ',ipntr
 if (ipntr eq  1) then stop
 ;....
 r_step=4
 w=20.0d0; 1.168547654d0	; half-width of fan in degrees degrees
 num1=cangle(0)+w
 num2=cangle(0)-w
 num3=num1+180
 num4=num2+180
 if (ipntr eq -1) then begin
; DS fan
     idx=where(xline lt x0 and (theta gt num2 and theta le num1))
; BS fan
     if (num3 gt 360) then jdx=where(xline ge x0 and (theta gt num4  or theta le (num3 mod 360)))
     if (num3 le 360) then jdx=where(xline ge x0 and (theta gt num4  and theta le num3))
     endif
 openw,66,'temporary.dat'
 markedupimage=im
 markedupimage(idx)=max(markedupimage)
 if (ifviz eq 1) then tvscl,markedupimage
 for r=max([0,radius-w1]),min([511,radius+w2]),r_step do begin
     kdx=where(radii(idx) ge r and radii(idx) lt r+r_step)
     markedupimage(idx(kdx))=0
     if (ifviz eq 1) then tvscl,markedupimage
     pixels=im(idx(kdx))
; actioninidcator=1 implies the image under treatment is the observed image, not the model.
     if (actioninidcator eq 1 and if_want_bootstrap eq 1) then pixels=bootstrapper(pixels)
     if (kdx(0) ne -1) then printf,66,-mean(radii(idx(kdx))),median(pixels),stddev(pixels)
     endfor
 markedupimage=im
 markedupimage(jdx)=max(markedupimage)
 if (ifviz eq 1) then tvscl,markedupimage
if (w3 ne w4) then begin
 for r=radius+w3,radius+w4,r_step do begin
     kdx=where(radii(jdx) ge r and radii(jdx) lt r+r_step)
     markedupimage(jdx(kdx))=0
     if (ifviz eq 1) then tvscl,markedupimage
     nfan=n_elements(kdx)
     pixels=im(jdx(kdx))
     if (if_want_bootstrap eq 1) then pixels=bootstrapper(pixels)
     if (nfan gt 30) then printf,66,mean(radii(jdx(kdx))),median(pixels),stddev(pixels)
     endfor
 endif
 close,66
 data=get_data('temporary.dat')
 rad=reform(data(0,*))
 line=reform(data(1,*))
 err_line=reform(data(2,*)) 
	idx=where(rad lt 0 and abs(rad) lt radius+5 and abs(rad) gt radius-5)
	if (idx(0) ne -1) then begin
	err_line(idx)=err_line(idx)*5
	endif else begin
	stop
	endelse
	idx=where(rad lt 0 and abs(rad) ge radius+5)
	if (idx(0) ne -1) then begin
	err_line(idx)=err_line(idx)/10
	endif else begin
	stop
	endelse
 if (ifviz eq 1) then ploterr,rad,line,err_line,psym=7
 ; modified err_line is now returned to calling routine
 return
 end
