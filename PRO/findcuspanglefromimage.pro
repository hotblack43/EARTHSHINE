 PRO findcuspanglefromimage,im,x0,y0,radius,cangle
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
