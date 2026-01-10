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

PRO adjust_x0y0radius_byhand,im,h,iflag
 iflag=314
 gofindradiusandcenter_fromheader,h,x0,y0,radius
 left=x0-radius
 right=x0+radius
 down=y0-radius
 up=y0+radius
 window,xsize=1600,ysize=700
w=6
 x=findgen(512)
 plot,avg(im(*,Y0-w:y0+w),1),/ylog,yrange=[0.1,70000],ystyle=3
 oplot,[left,left],[0.01,100000.],color=fsc_color('red')
 oplot,[right,right],[0.01,100000.],color=fsc_color('red')
 cursor,a,b
 if (a gt 511) then goto, badfile
 wait,0.3
;plot,im(*,Y0),yrange=[min(im),min(im)+30],ystyle=3
 plot,avg(im(*,Y0-w:y0+w),1),/ylog,yrange=[0.1,70000],ystyle=3
 oplot,[left,left],[!Y.crange],color=fsc_color('red')
 oplot,[right,right],[!Y.crange],color=fsc_color('red')
 cursor,a2,b2
 if (a2 gt 511) then goto, badfile
 wait,0.3
 radiusx=(max([a,a2])-min([a,a2]))/2.0
 newX0=min([a,a2])+radiusx
 print,a,a2,b,b2
;
 plot,im(X0,*),/ylog,yrange=[0.1,70000],ystyle=3
 oplot,[up,up],[0.1,100000L],color=fsc_color('red')
 oplot,[down,down],[0.1,100000L],color=fsc_color('red')
 cursor,a,b
 if (a gt 511) then goto, badfile
 wait,0.3
 plot,im(X0,*),yrange=[min(im),min(im)+30],ystyle=3
 oplot,[up,up],[!Y.crange],color=fsc_color('red')
 oplot,[down,down],[!Y.crange],color=fsc_color('red')
 cursor,a2,b2
 if (a2 gt 511) then goto, badfile
 print,a,a2,b,b2
 wait,0.3
 radiusy=(max([a,a2])-min([a,a2]))/2.0
 newY0=min([a,a2])+radiusy
 print,'Detected x0,y0,radisu1,radius2:',newX0,newY0,radiusx,radiusy
 print,'OLd      x0,y0,radisu1,radius2:',X0,Y0,radius
newRADIUS=(radiusx+radiusy)/2.0
 sxaddpar, h, 'X0-ADJ', newX0, 'Disc centre X hand-eye estimated'
 sxaddpar, h, 'Y0-ADJ', newY0, 'Disc centre Y hand-eye estimated'
 sxaddpar, h, 'R-ADJ', newRADIUS, 'Disc centre RADIUS hand-eye estimated'
 return
 badfile: 
 iflag=1
return
end

path='/data/pth/DARKCURRENTREDUCED/SELECTED_4d/'
files='badfiles_coordinatewise.txt'
 openr,1,files
while not eof(1) do begin
file=''
readf,1,file
 print,file
im=readfits(path+file,header)
adjust_x0y0radius_byhand,im,header,iflag
if (iflag eq 314) then writefits,'NEWFILES/'+file,im,header
if (iflag eq 1) then writefits,'BADFILES/'+file,im,header
print,'iflag was: ',iflag
endwhile
close,1
end
