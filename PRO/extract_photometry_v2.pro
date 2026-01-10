@stuff19.pro
 PRO gostripthename,str,basename
 xx=strpos(str,'245')
 basename=strmid(str,xx,strlen(str)-xx)
 return
 end


 PRO go_oplot_boxes,xli,xri,ydi,yui
 common vizualise,viz,alogim
 xl=xli(0)
 xr=xri(0)
 yd=ydi(0)
 yu=yui(0)
 for x=xl,xr,1 do alogim(x,yd)=max(alogim)
 for x=xl,xr,1 do alogim(x,yu)=max(alogim)
 for y=yd,yu,1 do alogim(xl,y)=max(alogim)
 for y=yd,yu,1 do alogim(xr,y)=max(alogim)
 if (viz eq 1) then contour,10^alogim,/isotropic,/cell_fill,xstyle=3,ystyle=3,color=fsc_color('white')
 return
 end

PRO fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
; Fits a circle that passes through the three designated coordinates
a=[[x1,y1,1.0],[x2,y2,1.0],[x3,y3,1.0]]
d=[[x1*x1+y1*y1,y1,1.0],[x2*x2+y2*y2,y2,1.0],[x3*x3+y3*y3,y3,1.0]]
e=[[x1*x1+y1*y1,x1,1.0],[x2*x2+y2*y2,x2,1.0],[x3*x3+y3*y3,x3,1.0]]
f=[[x1*x1+y1*y1,x1,y1],[x2*x2+y2*y2,x2,y2],[x3*x3+y3*y3,x3,y3]]
a=determ(a,/check,/double)
d=-determ(d,/check,/double)
e=determ(e,/check,/double)
f=-determ(f,/check,/double)
;
x0=-d/2./a
y0=-e/2./a
radius=sqrt((d*d+e*e)/4./a/a-f/a)
return
end

PRO gofindradiusandcenter,im_in,x0,y0,radius
 ; Will take an image - im_in- and return estimates of the radius and center coordinates
 ; The code is based on fitting circles to three points on the circle rim.
 im=im_in
 ; detect the edges of the BS
 im=laplacian(im,/CENTER)
 ; im treshold and remove some single pixels
 idx=where(im gt max(im)/4.)
 jdx=where(im le max(im)/4.)
 im(idx)=1
 im(jdx)=0
 ; remove specks
 im=median(im,3)
 ; find good estimates of the circle radius and centre
 ntries=100
 idx=where(im ne 0)
 coords=array_indices(im,idx)
 nels=n_elements(idx)
 openw,49,'trash.dat'
 for i=0,ntries-1,1 do begin 
     irnd=randomu(seed)*nels
     x1=reform(coords(0,irnd))
     y1=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x2=reform(coords(0,irnd))
     y2=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x3=reform(coords(0,irnd))
     y3=reform(coords(1,irnd))
     fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
     printf,49,x0,y0,radius
     endfor
 close,49
 spawn,'grep -v NaN trash.dat > aha.dat'
 spawn,'mv aha.dat trash.dat'
 data=get_data('trash.dat')
 x0=median(reform(data(0,*)))
 y0=median(reform(data(1,*)))
 radius=median(reform(data(2,*)))
	openw,47,'circle.dat' & printf,47,x0,y0,radius & close,47
 return
 end
 
 FUNCTION test_if_same_side,line,point1,point2
 ; Will test if two points are on the same side of a line
 ; INPUTS:
 ; line = [a1,a2,b1,b2], coords of two points ON the line
 ; point1 = [c1,c2], coords of the first point
 ; point2 = [d1,d2], coords of the second point
 a1=double(line(0))
 a2=double(line(1))
 b1=double(line(2))
 b2=double(line(3) )
 c1=double(point1(0))
 c2=double(point1(1))
 d1=double(point2(0))
 d2=double(point2(1))
 stat1=crossp([a1-c1,a2-c2,0],[a1-b1,a2-b2,0])
 stat2=crossp([a1-d1,a2-d2,0],[a1-b1,a2-b2,0])
 test=(stat1(2)/abs(stat1(2)) eq stat2(2)/abs(stat2(2)))
 ;print,stat1,stat2
 return,test
 end
 
 PRO find_circle_inside_outside,radius,CENTER,inside,outside,l,idx_inside,idx_outside
 common lineandpoint,line,point1
 inside=intarr(l)
 outside=intarr(l)
 radius2=radius^2
 ;..........
 for i=0,l(0)-1,1 do begin
     for j=0,l(1)-1,1 do begin
         r2= (i-CENTER(0))^2+(j-CENTER(1))^2
         ;if (r2 gt radius2 and test_if_same_side(line,point1,[i,j,0]) eq 1) then outside(i,j)=1 ELSE inside(i,j)=1
         if (r2 gt radius2) then outside(i,j)=1 ELSE inside(i,j)=1
         endfor
     endfor
 idx_inside=where(inside eq 1)
 idx_outside=where(outside eq 1)
 return
 end

PRO get_circle,l,coords,circle,radius,maxval
circle=fltarr(l)*0.0
astep=0.1d0
x0=coords(0)
y0=coords(1)
for angle=0.0d0,360.0d0-astep,astep do begin
	x=x0+radius*cos(angle*!dtor)
	y=y0+radius*sin(angle*!dtor)
	if ((x ge 0 and x le l(0)-1) and (y ge 0 and y le l(1)-1)) then circle(x,y)=maxval
endfor
return
end
 PRO get_observed_image,inname,observed_image,filtername,JD
 common circleSTUFF,circle,radius,moon_coords
 common vizualise,viz,alogim
 observed_image=readfits(inname,header,/SIL)
;..
get_info_from_header,header,'DMI_COLOR_FILTER',filtername
get_info_from_header,header,'FRAME',JD
;..
 l=size(observed_image,/dimensions)
 gofindradiusandcenter,observed_image,x0,y0,radius
 radius=radius*1.05
 moon_coords=[x0,y0]
 get_circle,l,moon_coords,circle,radius,max(observed_image)
 ;----------------------------------------------------------
 ; Build a composite image of Moon and circle
 imin2=observed_image+circle
 alogim=alog(imin2)
 ;----------------------------------------------------------
 ; find the inside and the outside of the circle around the Moon
 find_circle_inside_outside,radius,moon_coords,inside,outside,l,idx_inside,idx_outside
 im3=outside     ; the skymask
 im2=observed_image
 return
 end
 
 ;.....................................................................................
 ; Code that extracts photometry from images of the Moon. Basic method is to find
 ; Moon center and rim and then define some boxes on the surface in the DS and the BS.
 ; Future versions must learn to 'navigate' on the surface so that libration and Earth-Moon
 ; distance-variations are taken into account.
 ;.....................................................................................
 ; Version 2: finds the files to read by itself and runs a loop
 ;.....................................................................................
 common paths,path
 common vizualise,viz,alogim
 common lineandpoint,line,point1
 t1=systime(/julian)
 ;----------------------------------------------------------
 openw,55,'skippedfiles.txt'
 openw,87,'BBSO.results.dat'
 path='./'
 viz=0
 line=[256,0,256,511]
 point1=[511,0]
 usepath='BBSO_CLEANED_IMAGES/'
 files=file_search(usepath+'BBSO_CLEAN_*.fits',count=n)
 for i=0,n-1,1 do begin
 observed_image_name=files(i)
 get_observed_image,observed_image_name,observed_image,filtername,JD
 l=size(observed_image,/dimensions)
 gostripthename,files(i),basename
 flagsfilename=strcompress(usepath+'cleanedflags_'+basename,/remove_all)
 flags=readfits(flagsfilename,/sil)
 ;----------------------------------------------------------
 ; First find center and radius of the lunar disc
 im_in=observed_image
 gofindradiusandcenter,im_in,x0,y0,radius
 ; Then define the boxes relative to x0,y0
 data=get_data('photometry_boxes.relcoords')
 DSoffsetL=reform(data(0,0))	; offset from x0 to left side of DS box
 DSoffsetR=reform(data(1,0))
 DSoffsetD=reform(data(2,0))	; offset from x0 to bottom of DS box
 DSoffsetU=reform(data(3,0))
 BSoffsetL=reform(data(0,1))	; offset from x0 to left side of BS box
 BSoffsetR=reform(data(1,1))
 BSoffsetD=reform(data(2,1))	; offset from x0 to bottom of BS box
 BSoffsetU=reform(data(3,1))
 bigflag=0
 xL=x0+DSoffsetL
 xR=x0+DSoffsetR
 yD=y0+DSoffsetD
 yU=y0+DSoffsetU
 if (xL lt 0 or xR ge l(0)-1 or yD lt 0 or yU ge l(1)-1) then bigflag=911
 go_oplot_boxes,xL,xR,yD,yU
 ; extract DS
 DS=911 
 if (bigflag ne 911) then begin
 DS=im_in(xL:xR,yD:yU)
 DSflags=flags(xL:xR,yD:yU)
 endif
 stopflagDS=0
 stopflagBS=0
 if (product(DSflags) eq 0) then stopflagDS=1
 ; extract BS
 xL=x0+BSoffsetL
 xR=x0+BSoffsetR
 yD=y0+BSoffsetD
 yU=y0+BSoffsetU
 if (xL lt 0 or xR ge l(0)-1 or yD lt 0 or yU ge l(1)-1) then bigflag=911
 go_oplot_boxes,xL,xR,yD,yU
 BS=911 
 if (bigflag ne 911) then begin
 BS=im_in(xL:xR,yD:yU)
 BSflags=flags(xL:xR,yD:yU)
 endif
 if (product(BSflags) eq 0) then stopflagBS=1
 if (stopflagDS eq 1) then begin
	printf,55,format='(a,1x,a,1x,a,1x,i2,1x,i2)','Had to skip the file: ',files(i),' flags were: ',stopflagDS,stopflagBS
	print,format='(a,1x,a,1x,a,1x,i2,1x,i2)','Had to skip the file: ',files(i),' flags were: ',stopflagDS,stopflagBS
 endif else begin
 relerr=sqrt((stddev(BS)/sqrt(n_elements(BS))/mean(BS))^2+(stddev(DS)/sqrt(n_elements(DS))/mean(DS))^2)
 print,format='(a,2(1x,f16.9),a,1x,a,1x,f17.6)','BS/DS: ',mean(BS)/mean(DS),relerr*100.,' %',filtername,JD
 printf,87,format='(f19.7,2(1x,g12.6),1x,a)',JD,mean(BS)/mean(DS),relerr*100.,filtername
 endelse
 ;----------------------------------------------------------
 t2=systime(/julian)
 print,'That took ',24.*3600.*(t2-t1),' seconds.'
 endfor
 close,87
 close,55
 end
 
