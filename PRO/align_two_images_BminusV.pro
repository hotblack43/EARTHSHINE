PRO get_BandVimagesandBminusV,im,Bhead,reference,Vhead,B,V,BminusV
; get the exp times
get_EXPOSURE,Bhead,Bexptime
get_EXPOSURE,Vhead,Vexptime
; get the flats
Vflat=readfits('FLATS/FLATJD2455827/CFN1__V_.fits')
Bflat=readfits('FLATS/FLATJD2455827/CFN1__B_.fits')
print,'Mean and median of V flat: ',mean(Vflat),median(Vflat)
print,'Mean and median of B flat: ',mean(Bflat),median(Bflat)
ifFF='no';	write yes or no
; apply the flats
if (ifFF eq 'yes') then begin
im=im/Bflat
reference=reference/Vflat
endif
;
Bim=im
Vim=reference
; align disc centre to image center
;manual_align,im,reference,offset,diff
auto_align,Bim,Bhead,Vim,Vhead
; calculate the mag images
bmv=11.25
niter=20
Vinst = -2.5*alog10(Vim/Vexptime(0)) - 2.477*0.10 
Binst = -2.5*alog10(Bim/Bexptime(0)) - 2.545*0.15
for iter=0,niter-1,1 do begin
V = Vinst + 15.07 - 0.05*bmv
B = Binst + 14.75 + 0.21*bmv 
bmv=mean(B,/NaN)-mean(V,/NaN)
print,mean(B,/NaN),mean(V,/NaN),bmv
endfor
writefits,'Bimage.fits',B
writefits,'Vimage.fits',V
writefits,'BminusV.fits',B-V
BminusV=B-V
return
end

PRO auto_align,im,Bhead,reference,Vhead
gofindradiusandcenter_fromheader,Bhead,Bx0,By0,Bradius
gofindradiusandcenter_fromheader,Vhead,Vx0,Vy0,Vradius
im=shift(im,256-Bx0,256-By0)
reference=shift(reference,256-Vx0,256-Vy0)
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
     radius=float(strmid(header(jdx),15,9))
     endelse
 return
 end

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 exptime=exptime(0)
 return
 end

PRO manual_align,im,reference,offset,diff
	k=0
  	l=size(im,/dimensions)
	Nx=l(0)*1.0
	Ny=l(1)*1.0
  	offset = alignoffset(im, reference, corr)
        offset=[offset(0),offset(1),0.0]
; First get rough offset from 'alignoffset'
        shifted_im=shift_sub(im,-offset(0),-offset(1))
  window,3,xsize=512,ysize=512
  tvscl,congrid(shifted_im-reference,512,512)
key='q'
print,'Press R,L,u,d,l or r key - q to quit'
start:
	key=get_kbrd()
	print,key
	dx=0.0
	dy=0.0
        da=0.0
        da=0.0
	if (key eq 'u') then begin
	dy=0.1
	endif	
	if (key eq 'd') then begin
	dy=-0.1
	endif	
	if (key eq 'r') then begin
	dx=0.1
	endif	
	if (key eq 'l') then begin
	dx=-0.1
	endif	
	if (key eq 'R') then begin
	da=0.1
	endif	
	if (key eq 'L') then begin
	da=-0.1
	endif	
	offset(0)=offset(0)+dx
	offset(1)=offset(1)+dy
	offset(2)=offset(2)+da
  shifted_im=shift_sub(im,-offset(0),-offset(1))
  shifted_im=ROT(shifted_im,offset(2))
  window,3,xsize=512,ysize=512
  diff=(float(shifted_im)-float(reference))/float(reference)
	print,'Sum of square diff: ',total(diff^2)
  window,3,xsize=512,ysize=512
loadct,13
  tvscl,hist_equal(diff)
window,1
!P.MULTI=[0,1,2]
plot,yrange=[-100,100],diff(*,256),xtitle='Column #'
plot,yrange=[-100,100],diff(256,*),xtitle='Row #'
if (key ne 'q') then goto, start
reference=shifted_im
return
end

; First the EFM cleaned images
im=readfits('EFMCLEANED_0p7MASKED/2456034.1142920MOON_B_AIR_DCR.fits',Bhead)
reference=readfits('EFMCLEANED_0p7MASKED/2456034.1164417MOON_V_AIR_DCR.fits',Vhead)
get_BandVimagesandBminusV,im,Bhead,reference,Vhead,B,V,BminusVimage
; Then the BBSO-linear cleaned images
;im=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/BBSO_CLEANED/2456034.1142920MOON_B_AIR_DCR.fits',Bhead)
;reference=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/BBSO_CLEANED/2456034.1164417MOON_V_AIR_DCR.fits',Vhead)
;get_BandVimagesandBminusV,im,Bhead,reference,Vhead,B,V,BminusVimage
; Then the BBSO-log cleaned images
;im=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/BBSO_CLEANED_LOG/2456034.1142920MOON_B_AIR_DCR.fits',Bhead)
;reference=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/BBSO_CLEANED_LOG/2456034.1164417MOON_V_AIR_DCR.fits',Vhead)
;get_BandVimagesandBminusV,im,Bhead,reference,Vhead,B,V,BminusVimage
;
imEFM=BminusVimage
; Then the raw (i.e. bias-subtracted) images
im=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456034.1142920MOON_B_AIR_DCR.fits',Bhead)
reference=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1//2456034.1164417MOON_V_AIR_DCR.fits',Vhead)
get_BandVimagesandBminusV,im,Bhead,reference,Vhead,Braw,Vraw,BminusV_RAW_image
imRAW=BminusV_RAW_image
!P.CHARTHICK=4
!P.THICK=4
!X.THICK=4
!Y.THICK=4
!P.MULTI=[0,1,2]
set_plot,'ps'
device,/color
device,xsize=18,ysize=24.5,yoffset=2
device,filename='BminusV_2456034.ps'
w=3
plot,avg(imEFM(*,256-w:256+w),1),charsize=2,xstyle=3,title='JD2456034',xtitle='Column #',ytitle='B-V (red=DCR)',yrange=[-2,2]
oplot,avg(imRAW(*,256-w:256+w),1),color=fsc_color('red')
plot,avg(imEFM(*,256-w:256+w),1)-avg(imRAW(*,256-w:256+w),1),charsize=2,xstyle=3,title='JD2456034',xtitle='Column #',ytitle='!7D!3B-V',yrange=[-.2,.2]
plots,[120,120],[!Y.crange],linestyle=1
plots,[343,343],[!Y.crange],linestyle=1
device,/close
end
