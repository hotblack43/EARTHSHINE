PRO extract2regions,im,lon,lat,DS,BS,tot
common ims,imshow
lon0=-60
lat0=17
w=3
idx=where(lon gt lon0-w and lon lt lon0+w and lat gt lat0-w and lat lt lat0+w)
nidx=n_elements(idx)
reg1=total(im(idx),/double)
reg1=-2.5*alog10(reg1)+2.5*alog10(6.67*6.67)+2.5*alog10(nidx)
lon0=60
lat0=16
jdx=where(lon gt lon0-w and lon lt lon0+w and lat gt lat0-w and lat lt lat0+w)
njdx=n_elements(idx)
reg2=total(im(jdx),/double)
reg2=-2.5*alog10(reg2)+2.5*alog10(6.67*6.67)+2.5*alog10(njdx)
if (reg2 gt reg1) then begin
	BS=reg1
	DS=reg2	
endif else begin
	BS=reg2
	DS=reg1
endelse
idxtot=where(im gt ds-2)
ntot=n_elements(idxtot)
tot=total(im(idxtot),/double)
tot=-2.5*alog10(tot)+2.5*alog10(6.67*6.67)+2.5*alog10(ntot)
imshow(idx)=max(imshow)
imshow(jdx)=max(imshow)
return
end

PRO getJDfromfilename,name,JD,yesIhavealonlatfile,lon,lat
   idx=strpos(name,'245')
   JD=double(strmid(name,idx(0),15))
   lonlatfound=file_search('OUTPUT/','lonla*'+strmid(name,idx(0),15)+'*')
   yesIhavealonlatfile=0
   if (file_exist(lonlatfound) eq 1) then begin
	yesIhavealonlatfile=1
        lonlatfile=readfits(lonlatfound,/sil)
        lon=reform(lonlatfile(*,*,0))
        lat=reform(lonlatfile(*,*,1))
	endif
return
end

common ims,imshow
files=file_search('/media/thejll/OLDHD/MIXED117/*.fits',count=n)
openw,33,'synmodel_data.dat'
for i=0,n-1,1 do begin
im=double(readfits(files(i),h,/sil))
imshow=im
getJDfromfilename,files(i),JD,yesIhavealonlatfile,lon,lat
mphase,jd,illfrac
if (yesIhavealonlatfile eq 1) then begin
extract2regions,im,lon,lat,DS,BS,tot
tvscl,imshow
printf,33,format='(f15.7,4(1x,f10.7))',jd,illfrac,ds,bs,tot
print,format='(f15.7,4(1x,f10.7))',jd,illfrac,ds,bs,tot
endif else begin
	print,'stop'
endelse
endfor	; end over 177 files
close,33
data=get_data('synmodel_data.dat')
jd=reform(data(0,*))
k=reform(data(1,*))
ds=reform(data(2,*))
bs=reform(data(3,*))
tot=reform(data(4,*))
plot,ystyle=3,k,ds,psym=7,xtitle='Illuminated fraction',ytitle='DS and TOT [mag]'
oplot,k,tot,psym=7
end
