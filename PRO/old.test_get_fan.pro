PRO use_cusp_angle_build_fan,im,JD,x0,y0,radius,rad,line
 disp=im
 l=size(im,/dimensions)
;
 cangle=-cusp_angle(JD,'mlo')/!dtor
 if (cangle(0) lt 0) then cangle=90.+cangle(0)
print,'cangle:',cangle
stop
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
;contour,theta,/downhill,levels=findgen(36)*10$
;,c_labels=findgen(36)*0+1
;
;stop
 ;....
 ; find the DS
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
tvscl,disp
stop
 ;
 rad=dblarr(512)*0-911
 line=dblarr(512)*0-911
 ic=0
 for r=radius-inrange,radius+outrange,r_step do begin
     jdx=where(radii(idx) gt r and radii(idx) le r+r_step)
;help,r,jdx
     if (jdx(0) ne -1) then begin
         rad(ic)=median(radii(idx(jdx)))
         line(ic)=median(im(idx(jdx)))
;        print,rad(ic),line(ic)
disp(idx(jdx))=min(disp)
tvscl,disp
         endif
     ic=ic+1
     endfor
 kdx=where(rad ne -911)
 rad=rad(kdx)
 line=line(kdx)
 return
 end
 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end

 PRO gofindradiusandcenter_fromheader,header,x0,y0,radius
 ; Will take a header and read out DISCX0, DISCY0 and RADIUS
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCX0 not in header. Assigning dummy value'
     x0=256.
     endif else begin
     x0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCY0 not in header. Assigning dummy value'
     y0=256.
     endif else begin
     y0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     radius=float(strmid(header(jdx),11,19))
     endelse
 x0=x0(0)
 y0=y0(0)
 radius=radius(0)
 return
 end




;--------------------------------
openr,1,'listtodo.txt'
str=''
while not eof(1) do begin
 readf,1,str
 print,str
 if (str eq 'stop' or str eq 'STOP') then GOTO,stop
 im=readfits(str,h)
 get_time,h,JD
 gofindradiusandcenter_fromheader,h,x0,y0,radius
 ;..................
 use_cusp_angle_build_fan,im,jd,x0,y0,radius,rad,line
 plot,rad,line
 endwhile
STOP:
 close,1
 end
 
