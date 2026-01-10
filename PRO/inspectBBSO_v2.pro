PRO bestBSspotfinder,im,cg_x,cg_y
; find the coordinates of a spot near the brightest part of the BS
 l=size(im,/dimensions)
smooim=median(im,5)
idx=where(smooim eq max(smooim))
coo=array_indices(smooim,idx)
cg_x=coo(0)
cg_y=coo(1)
if (cg_x lt 0 or cg_x gt l(0) or cg_y lt 0 or cg_y gt l(1)) then stop
return
end

 PRO get_filtername,header,name
 ;
 idx=where(strpos(header, 'DMI_COLOR_FILTER') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 name=strmid(str,29,8)
 name=strcompress('_'+name+'_',/remove_all)
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

PRO gofindradiusandcenter,im_in,x0,y0,radius
 ; Will take an image - im_in- and return estimates of the radius and center coordinates
 ; The code is based on fitting circles to three points on the circle rim.
 im=im_in
 ; detect the edges of the BS
 im=sobel(im)
 ;im=laplacian(im,/CENTER)
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
     ;oplot,[x1,x1],[y1,y1],psym=7
     fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
     printf,49,x0,y0,radius
     endfor
 close,49
 data=get_data('trash.dat')
 x0=median(reform(data(0,*)))
 y0=median(reform(data(1,*)))
 radius=median(reform(data(2,*)))
 return
 end

PRO gofindDSandBSinboxes,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS,iflag
; determine if BS is to the right or the left of the center
; iflag = 1 means position 1
; iflag = 2 means position 2
if (iflag eq 1) then ipos=4./5.
if (iflag eq 2) then ipos=2./3.
if (cg_x-w lt 0 or cg_x+w gt 511 or cg_y-w lt 0 or cg_y+w gt 511) then stop
if (x0+radius*ipos-w lt 0 or x0-radius*ipos+w gt 511 or y0-w lt 0 or y0+w gt 511) then stop

if (cg_x gt x0) then begin
; BS is to the right
BSim=(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DSim=(im(x0-radius*ipos-w:x0-radius*ipos+w,y0-w:y0+w))
endif

if (cg_x lt x0) then begin
; BS is to the left
BSim=(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DSim=(im(x0+radius*ipos-w:x0+radius*ipos+w,y0-w:y0+w))
endif

BS=911
DS=811
if (finite(median(BSim)) eq 1) then BS=median(BSim)
if (finite(median(DSim)) eq 1) then DS=median(DSim)
return
end

PRO cgfinder,im,cg_x,cg_y
; find c.g.
 l=size(im,/dimensions)
 meshgrid,l(0),l(1),x,y
 cg_x=total(x*im)/total(im)
 cg_y=total(y*im)/total(im)
if (cg_x lt 0 or cg_x gt l(0) or cg_y lt 0 or cg_y gt l(1)) then stop
return
end

 
 PRO getFITSname,str_in,fitsname
 str=str_in
 arr=strsplit(str,'/',/extract)
 fitsname=arr(n_elements(arr)-1)
 return
 end
 
 
 PRO getbasepath,str,basepath
 basepath=strcompress(str+'/',/remove_all)
 return
 end
 
 PRO parseit,str,part1,part2
 idx=strpos(str,' ')
 part1=strmid(str,0,idx)
 part2=strmid(str,idx+1,strlen(str))
 return
 end
 
 PRO parse_str,s_in,a,b,c,w
 s=' '+s_in+' '
 j=0
 openw,5,'junk.dat'
 for i=1,strlen(s)-1,1 do begin
     if (strmid(s,i,1) eq ' ') then begin
         ss=strmid(s,j,i-j)
         if (valid_num(ss) ne 0) then printf,5,ss
         j=i
         endif
     endfor
 close,5
 data=get_data('junk.dat')
 a=data(0,0)
 b=data(0,1)
 c=data(0,2)
 w=data(0,3)
 return
 end
 


 ;---------------------------------------------------------------------------------------
 ; Code to inspect output from the BBSO linear method applied to real observations
 ;---------------------------------------------------------------------------------------
 common vizualize,viz
 viz=0
 ww=11
 nn=512
 im=fltarr(nn,nn)
 mask=fltarr(nn,nn)
 model=fltarr(nn,nn)
 observed=fltarr(nn,nn)
 !P.MULTI=[0,1,2]
 !P.CHARSIZE=1.3
 ;---------------------------------------------------------------------------------------
 ; point to base path for the observed images 
 obspath='/media/SAMSUNG/CLEANEDUP2455917/'
 ; collect all images
 files=file_search(strcompress(obspath+'2455*.fits',/remove_all),count=n)
 openw,77,'results_BBSO_lin_and_log_2455917.txt'
 ;..........................
 for ifil=0,n-1,1 do begin
 for iflog=1,2,1 do begin	; set 1 or 2 for  yes/no on log10 images
 ; point to where all the cleaned-up output is
 if (iflog eq 1) then cleanedpath=obspath+'/BBSO_CLEANED_LOG/'
 if (iflog eq 2) then cleanedpath=obspath+'/BBSO_CLEANED/'
     getFITSname,files(ifil),fitsname
     ; Get the observed image
     observed=readfits(strcompress(obspath+fitsname,/remove_all),/silent,header)
      if (max(observed) gt 10000 and max(observed) lt 55000) then begin
     get_time,header,JD
     ; find the center of gravity
    ; cgfinder,observed,cg_x,cg_y
     bestBSspotfinder,observed,cg_x,cg_y
     ; find the center and radius
     gofindradiusandcenter,observed,x0,y0,radius
     ; Get the cleaned image
     im=readfits(cleanedpath+fitsname,/silent)
     get_filtername,header,filtername
 for iflag=1,2,1 do begin	; set 1 or 2 for 4/5ths or 2/3rds of radius to place DS patch
; get DS,BS ratio in the cleanedup image 
	gofindDSandBSinboxes,im,im,x0,y0,radius,cg_x,cg_y,ww,dummy,DScleaned,iflag
        printf,77,format='(f15.7,3(1x,f6.1),2(1x,f20.6),2(1x,i3),1x,a)',jd,x0,y0,radius,total(observed,/double),DScleaned,iflag,iflog,filtername
        print,format='(f15.7,3(1x,f6.1),2(1x,f20.6),2(1x,i3),1x,a)',jd,x0,y0,radius,total(observed,/double),DScleaned,iflag,iflog,filtername
     endfor
endif
 endfor
 endfor

 close,77
 end
