



; code to test whether RON has zero mean - i.e. whether co-adding images
; leaves the mean alone
ntries=100
file='/media/SAMSUNG/EARTHSHINE/MOONDROPBOX/JD2456015/2456015.7742682MOON_V_AIR.fits.gz'
org=readfits(file)
ref=reform(org(*,*,0))
l=size(org,/dimensions)
n=l(2)
w=4
RON=2.4
!P.MULTI=[0,1,3]
contour,/isotropic,avg(org,2),xstyle=3,ystyle=3
cursor,x0,y0
bias=readfits('superbias.fits')
openw,33,'data.dat'
oplot,[x0,x0],[!Y.crange],linestyle=1
oplot,[!x.crange],[y0,y0],linestyle=1
for i=0,n-1,1 do begin
im=org(*,*,i)-bias
; align with ref image
offset = alignoffset(ref,im,corr)
im=shift_sub(im,+offset(0),+offset(1))
tvscl,im-ref
;
area=im(x0-w:x0+w,y0-w:y0+w)
if (i eq 0) then sum=area
if (i gt 0) then sum=sum+area
printf,33,mean(sum)/float(i+1),stddev(sum/float(i+1)),mean(area)
endfor
close,33
data=get_data('data.dat')
plot,ystyle=3,data(0,*),psym=7,xtitle='# of frames added',ytitle='Mean of averaged subframe'
meanval=findgen(n)*0.0+mean(data(0,n-10:n-1))
oplot,meanval,linestyle=1
oplot,meanval+RON/sqrt(w*w*findgen(n))
oplot,meanval-RON/sqrt(w*w*findgen(n))
;
plot,ystyle=3,data(2,*),psym=7,xtitle='# of frames added',ytitle='Mean of subframe'
end
