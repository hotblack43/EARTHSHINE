PRO use_cusp_angle_build_fan,im,x0,y0,radius,rad,line,imethod
 common thetaflags,iflag_theta,radii,theta,xline,yline
 disp=im
 l=size(im,/dimensions)
 ;
;if(iflag_theta ne 314) then begin
 radii=fltarr(l)
 theta=fltarr(l)
 xline=intarr(l)
 yline=intarr(l)
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
;iflag_theta=314
;endif
 ;....
         findcuspanglefromimage,im,x0,y0,radius(0),cangle
         print,'cangle:',cangle
 ;....
 left=avg(im(0:x0,*))
 right=avg(im(x0:511,*))
 print,'left,right:',left,right
 ipointer=1
 if (left lt right) then ipointer=-1
 ;....
 r_step=5
 inrange=r_step*10
 outrange=r_step*13
 w=40.	; degrees
 if (ipointer eq  1) then idx=where(theta ge cangle(0)-w and theta lt cangle(0)+w and xline gt x0)
 if (ipointer eq -1) then idx=where(theta ge cangle(0)-w and theta lt cangle(0)+w and xline lt x0)
 disp(idx)=max(im)
;tvscl,disp
 ;
 rad=dblarr(512)*0-911
 line=dblarr(512)*0-911
 ic=0
 for r=radius(0)-inrange,radius(0)+outrange,r_step do begin
     jdx=where(radii(idx) gt r and radii(idx) le r+r_step)
     ;help,r,jdx
     if (jdx(0) ne -1) then begin
         rad(ic)=median(radii(idx(jdx)))
	if (imethod eq 1) then begin
         line(ic)=median(im(idx(jdx)))
	endif
	if (imethod eq 2) then begin
         line(ic)=mean(im(idx(jdx)),/double)
	endif
	if (imethod eq 3) then begin
         line(ic)=hmm(im(idx(jdx)))
	endif
         ;        print,rad(ic),line(ic)
         disp(idx(jdx))=min(disp)
;        tvscl,disp
         endif
     ic=ic+1
     endfor
 kdx=where(rad ne -911)
 rad=rad(kdx)
 line=line(kdx)
 return
 end
