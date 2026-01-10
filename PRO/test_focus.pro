ims=readfits('/data/pth/DATA/ANDOR/OUTDATA/JD2455482/Capella_darkreduced_0240.fits')
;ims=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455473/BBSO-33Frame-LO-r1-1.fits')
l=size(ims,/dimensions)
openw,11,'focus.dat'
for i=0,l(2)-1,1 do begin
im=ims(*,*,i)
z=ffT(im,-1)
zz=float(z*conj(z))
surface,zz,/zlog
focus=(total(zz)-zz(0,0))/zz(0,0)
print,i,focus
printf,11,i,focus
endfor
close,11
data=get_data('focus.dat')
;set_plot,'ps
!P.MULTI=[0,1,1]
plot,data(0,*),data(1,*)
!P.MULTI=[0,2,2]
for i=0,l(2)-1,1 do begin
contour,ims(*,*,i),/cell_fill,nlevels=101,/isotropic,title=strcompress('Image '+string(i)+'Focus :'+string(data(1,i))),xstyle=1,ystyle=1
endfor
device,/close
end
