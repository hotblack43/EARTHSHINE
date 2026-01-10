!P.CHARSIZE=2
path='/data/pth/DATA/ANDOR/MOONDROPBOX/'
name='Dark-clear-100frame-20ms.fits'
file=path+name
im=readfits(file)
l=size(im,/dimensions)
n=l(2)
openw,44,'imsdat.dat'
for i=0,n-1,1 do begin
subim=reform(im(*,*,i))
printf,44,mean(subim),stddev(subim)
endfor
close,44
data=get_data('imsdat.dat')
mns=reform(data(0,*))
std=reform(data(1,*))
plot,mns,title=name,xtitle='Image number',ytitle='Mean of image',ystyle=1,yrange=[95,103]
oploterr,mns,std
minz=min(im)
maxz=max(im)
;!P.MULTI=[0,5,4]
;for i=0,n-1,1 do begin
;subim=reform(im(*,*,i))
;histo,subim,minz,maxz,1
;endfor
!P.MULTI=[0,1,2]
plot,im(*,*,38),im(*,*,39),xtitle='Image 38',ytitle='Image 39',psym=7,xrange=[85,110],yrange=[85,110],xstyle=1,ystyle=1
plot,im(*,*,40),im(*,*,39),xtitle='Image 40',ytitle='Image 39',psym=7,xrange=[85,110],yrange=[85,110],xstyle=1,ystyle=1
end
