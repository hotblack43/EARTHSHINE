PRO getJDfromname,filename,JD
 bits=strsplit(filename,'/',/extract)
 parts=strsplit(bits(6),'MOON',/extract)
 JD=double(parts(0))
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
 
 ;str="find /media/thejll/SAMSUNG/EARTHSHINE/DARKCURRENTREDUCED/SELECTED_1/ -name '245*MOON_*' | grep _V_ > allfiles"
 ;spawn,str
 monthname=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
 goodlist=get_data('Chris_list_good_images.txt')
 openr,1,'allfiles'
 name=''
 ic=0
 while not eof(1) do begin
     readf,1,name
     getJDfromname,name,JD
     if (where(goodlist eq jd) ne -1) then begin
         im=readfits(name,header,/silent)
         gofindradiusandcenter_fromheader,header,x0,y0,radius
         window,1,xsize=1024,ysize=512
         im1=shift(im,256-x0,256-y0)
         print,min(im1),max(im1)
         im2=(hist_equal(im1,max=max(im1),minv=-4))*max(im1)/255.
         print,min(im2),max(im2)
         im3=[im1,im2]
         tvscl,im3
	 caldat,jd,mm,dd,yy,hh,mi,se
         notes1=' V filter '+string(yy,format='(i4)')+' '+monthname(mm)+' '+string(dd,format='(i2)')+' at '+string(hh,format='(i2)')+':'+string(mi,format='(i2)')+':'+string(se,format='(i2)')+' UTC'
         notes2='From Mauna Loa, with DMI/Lund Earthshine telescope.'
         xyouts,0.1,0.9,notes2,/DATA
         xyouts,0.1,0.87,string(JD,format='(f15.7)')+notes1,/DATA
         if (ic lt 10) then framename=strcompress('frame000'+string(ic),/remove_all)
         if (ic ge 10 and ic lt 100) then framename=strcompress('frame00'+string(ic),/remove_all)
         if (ic ge 100 and ic lt 1000) then framename=strcompress('frame0'+string(ic),/remove_all)
         write_jpeg,'MOVIE/'+framename+'.jpg',tvrd()
        ;write_jpeg,'MOVIE/'+framename+'.jpg',bytscl(im3)
         ic=ic+1
         endif
     endwhile
 close,1
 end
