PRO squish,array,mingoal,maxgoal
l=size(array,/dimensions)
ncol=l(0)
nrows=l(1)
minval=min(array(0:ncol-2,*))
maxval=max(array(0:ncol-2,*))
print,'Original min,max: ',minval,maxval
;
scaledarray=array(0:ncol-2,*)
scaledarray=(scaledarray-minval)/(maxval-minval)
array(0:ncol-2,*)=scaledarray
minval=min(array(0:ncol-2,*))
maxval=max(array(0:ncol-2,*))
print,'Scaled min,max: ',minval,maxval
array(ncol-1,*)=fix(array(ncol-1,*)*1000)
col=array(0,*)*0+1
array=[col,array]
return
end
PRO getrow,n,im_in,albedo,row
im=alog10(im_in)
wid=512
nwid=fix(wid/float(n))
row=[]
for i=0,n-1,1 do begin
; ]  [
for j=0,n-1,1 do begin
from_i=i*nwid
to_i=(i+1)*nwid
from_j=j*nwid
to_j=(j+1)*nwid
subim=im(from_i:to_i,from_j:to_j)
row=[row,mean(subim)]
endfor
endfor
row=[row,albedo]
return
end



;====================================
; code tos et up a lot of data from model images
; outputis suitable for a linear regression, as well as forest.py
; V2. Pedestal term added

im0=readfits('im1.fits')
im1=readfits('im2.fits')
eshine=max(im1)/5000.0
im0=shift(im0,40,-50)
im1=shift(im1,40,-50)
writefits,'im0_org_s.fits',im0;/total(im0)
writefits,'im1_org_s.fits',im1;/total(im1)
close,/all
n=25	; make nxn boxes across the imahe
fmtstr='('+string(n*n+1)+'(f11.5)'+')'
openw,2,'/data/pth/TABLE_TOTRAIN.DAT'
for alfa=1.4,3.0/1.61,0.01 do begin
	print,'---------------------------------------'
	str="./justconvolve im0_org_s.fits im0_c.fits "+string(alfa)
	spawn,str
	im0_c=readfits('im0_c.fits')
	str="./justconvolve im1_org_s.fits im1_c.fits "+string(alfa)
	spawn,str
	im1_c=readfits('im1_c.fits')
	for albedo=0.2,0.5,0.003 do begin
	for pedestal = eshine/10.,eshine,eshine/11. do begin
		iim=im1_c*albedo+im0_c*(1.-albedo) + pedestal
		iim=iim/total(iim,/double)
		getrow,n,iim,albedo,row
		printf,2,row,format=fmtstr
	endfor	; end pedestal loop
;print,row,format=fmtstr
	endfor	; end albedoloop
endfor	; end alfa loop
print,'---------------------------------------'
close,2
; now squish
nstrplus1=string(n*n+1)
data=get_data('/data/pth/TABLE_TOTRAIN.DAT')
squish,data,0,1
openw,2,'scaled_array.dat'
printf,2,format='('+nstrplus1+'(f12.5,","),i4)',data
close,2
end
