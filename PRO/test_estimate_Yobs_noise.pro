PRO 	getx0y0radius,header,x0,y0,radius
 get_info_from_header,header,'DISCX0',x0
 get_info_from_header,header,'DISCY0',y0
 get_info_from_header,header,'RADIUS',radius
 if (x0 eq 0 and y0 eq 0) then begin
     print,'Second go at getting X0,Y0 ...'
     get_info_from_header,header,'X0',x0
     get_info_from_header,header,'Y0',y0
     get_info_from_header,header,'RADIUS',radius
     endif
 return
 end
 
 PRO findcuspanglefromimage_special,im,x0,y0,radius,cangle
 l=size(im,/dimensions)
 ;
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
 w=2
 ic=0
 for angle=0,360-w,w do begin
     idx=where(radii gt radius-5 and radii le radius+5 and theta ge angle and theta lt angle+w)
     ;    print,angle,mean(im(idx))
     if (ic eq 0) then liste=[angle+w/2.,mean(im(idx))]
     if (ic gt 0) then liste=[[liste],[angle+w/2.,mean(im(idx))]]
     ic=ic+1
     endfor
 minval=min(liste(1,*))
 maxval=max(liste(1,*))
 idx=where(liste(1,*) lt (maxval-minval)/500.)
 minangle=min(liste(0,idx))
 maxangle=max(liste(0,idx))
 print,'minangle,maxangle: ',minangle,maxangle
 cangle=(minangle+maxangle)/2.
 return
 end
 
 PRO use_cusp_angle_fan_DS_BS_special,im,x0,y0,radius,rad,line,err_line,imethod,w1,w2,w3,w4
 common thetaflags,iflag_theta,radii,theta,xline,yline
 common namingstuff,JD,labelstr,markedupimage,if_smoo,if_jiggle,jiggle_ampl
 common cuspanglestuff,iflagcuspangle,cangle
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
 print,'determined num1,num2: ',num1,num2
 print,'determined num3,num4: ',num3,num4
 if (ipntr eq -1) then begin
     ; DS fan
     idx=where(xline lt x0 and (theta gt num2 and theta le num1))
     ; BS fan
     if (num3 gt 360) then jdx=where(xline ge x0 and (theta gt num4  or theta le (num3 mod 360)))
     if (num3 le 360) then jdx=where(xline ge x0 and (theta gt num4  and theta le num3))
     endif
 openw,66,'temp44.dat'
 markedupimage=im
 markedupimage(idx)=max(markedupimage)
 for r=max([0,radius-w1]),min([511,radius+w2]),r_step do begin
     kdx=where(radii(idx) ge r and radii(idx) lt r+r_step)
     markedupimage(idx(kdx))=0
     if (kdx(0) ne -1) then printf,66,-mean(radii(idx(kdx))),median(im(idx(kdx))),stddev(im(idx(kdx)))
     endfor
 markedupimage=im
 markedupimage(jdx)=max(markedupimage)
 if (w3 ne w4) then begin
     for r=radius+w3,radius+w4,r_step do begin
         kdx=where(radii(jdx) ge r and radii(jdx) lt r+r_step)
         markedupimage(jdx(kdx))=0
         nfan=n_elements(kdx)
         if (nfan gt 30) then printf,66,mean(radii(jdx(kdx))),median(im(jdx(kdx))),stddev(im(jdx(kdx)))
         endfor
     endif
 close,66
 data=get_data('temp44.dat')
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
 ; modified err_line is now returned to calling routine
 return
 end
 
 PRO estimate_Yobs_noise,stack,rad,linestack
 common stuff56,x0,y0,radius
 l=size(stack,/dimensions)
 nims=l(2)
 avim=avg(stack,2,/double,/nan)
 noise=[]
 linestack=[]
 for i=0,nims-1,1 do begin
     noise=[[[noise]],[[stack(*,*,i)-avim]]]
     im=reform(stack(*,*,i))
     w1=60  ; inside edge on DS sky
     w2=100 ; outside disc edge on DS disc
     w3=100 ; beyond edge on BS sky
     w4=w3; 120  ; beyond egde  on BS sky
     ; get the 'fan' for observations
     kmethod=3       ; i.e. mean halfmedian of annulus-segments
     use_cusp_angle_fan_DS_BS_special,im,x0,y0,radius,rad,line,err_line,kmethod,w1,w2,w3,w4
     linestack=[linestack,transpose(line)]
     endfor
 return
 end
 
 ;-------------------------------------------------------------------------------------
 ; Version 2. Code estimates noise along 'slice' given the JD.
 ; Assumes several files with that JD has been assembled in PEN/
 ;-------------------------------------------------------------------------------------
 PRO gofetchnoise,JDstr,rad,noisestack
 common stuff56,x0,y0,radius
 common cuspanglestuff,iflagcuspangle,cangle
 iflagcuspangle=1
 stack=[]
     files=file_search('PEN/*'+JDstr+'*',count=nfiles)
     for k=0,nfiles-1,1 do begin
         im=readfits(files(k),header)
         getx0y0radius,header,x0,y0,radius
         stack=[[[stack]],[[im]]]
         endfor
 im=reform(stack(*,*,2))
 findcuspanglefromimage_special,im,x0,y0,radius,cangle
 print,'Cangle=',cangle
 estimate_Yobs_noise,stack,rad,linestack
 plot,rad,stddev(linestack,dimension=1),psym=-7,xtitle='Distance from X0,y0 [pixels]',charsize=1.4,ytitle='S.D. along slice',title='Bootstrapped uncertainty estimates'
 avline=avg(linestack,0)
 plot,rad,stddev(linestack,dimension=1)/avline*100.,psym=-7,xtitle='Distance from X0,y0 [pixels]',charsize=1.4,ytitle='S.D. in pct of slice, along slice',title='Bootstrapped uncertainty estimates'
 l=size(linestack,/dimensions)
 nlines=l(0)
 noisestack=linestack*0.0
 for k=0,nlines-1,1 do begin
 noisestack(k,*)=linestack(k,*)-avline
 endfor
 return 
 end

 ;-------------------------------------------------------------------------------------
 ; Version 2. Code estimates noise along 'slice' given the JD.
 ; Assumes several files with that JD has been assembled in PEN/
 ;-------------------------------------------------------------------------------------
;common stuff56,x0,y0,radius
 get_lun,y15
 openr,y15,'listtodo_fn.simex_trials'
 while not eof(y15) do begin
     str=''
     readf,y15,str
     bits=strsplit(str,' ',/extract)
     JDstr=bits(0)
	gofetchnoise,JDstr,rad,noisestack
     endwhile
 close,y15
 free_lun,y15
 end
