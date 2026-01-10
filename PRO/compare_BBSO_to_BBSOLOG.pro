 FUNCTION get_JD_from_filename,name
 idx=strpos(name,'24')
 JD=double(strmid(name,idx,15))
 return,JD
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

;=========================================
; Code comparing BBSO_CLEANED to BBSO_CLEANED_LOG
file='Chris_list_good_images.txt'
openw,44,'rename.patches.dat'
openr,1,file
while not eof(1) do begin
str=''
readf,1,str
n1=0
n2=0
nam1='/media/thejll/OLDHD/ASTRO/EARTHSHINE/data/pth/DARKCURRENTREDUCED/SELECTED_10/BBSO_CLEANED/'+str+'*.fits'
fil1=file_search(nam1,count=n1)
jd=get_JD_from_filename(nam1)
print,jd
nam2='/media/thejll/OLDHD/ASTRO/EARTHSHINE/data/pth/DARKCURRENTREDUCED/SELECTED_10/BBSO_CLEANED_LOG/'+str+'*.fits'
fil2=file_search(nam1,count=n2)
if (n1 eq 1 and n2 eq 1) then begin
im1=readfits(nam1,h1,/silent)
im2=readfits(nam2,h2,/silent)
diff=(im1-im2)/im1*100
gofindradiusandcenter_fromheader,h1,x0,y0,radius
for rad_fra=0.55,0.99,0.1 do begin
x1=x0-radius*rad_fra
y1=y0
w=5
p1=mean(im1(x1-w:x1+w,y1-w:y1+w),/nan)
p2=mean(im2(x1-w:x1+w,y1-w:y1+w),/nan)
diff=(p1-p2)/p1*100
mphase,jd,illfrac
print,p1,p2,diff
printf,44,rad_fra,p1,p2,diff,illfrac
endfor
endif 
endwhile
close,1
close,44
; 
end
