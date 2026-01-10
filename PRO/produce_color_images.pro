@stuff93
common sizes,l
;----
getname,BIMname,'_B_'
getname,VIMname,'_V_'
getname,VE1imname,'_VE1_'
getname,VE2imname,'_VE2_'
getname,IRCUTimname,'_IRCUT_'
;----
getimage,BIMname,Bim,x0,y0,radius,Bam
getimage,VIMname,Vim,x0,y0,radius,Vam
idxBS=where(Vim gt 100)
getimage,VE1imname,VE1im,x0,y0,radius,VE1am
getimage,VE2imname,VE2im,x0,y0,radius,VE2am
getimage,IRCUTimname,IRCUTim,x0,y0,radiusm,IRCUTam
l=size(Bim,/dimensions)
;-------------------------------
;-------------------------------
;
idx=where(Vim gt 0) & Vinst=dblarr(512,512)
Vinst(idx) = -2.5*alog10(Vim(idx)) - Vam*0.1 ; kV=0.1
;.
jdx=where(Bim gt 0) & Binst=dblarr(512,512)
Binst(jdx) = -2.5*alog10(Bim(jdx)) - Bam*0.15 ; kB=0.15
;.
kdx=where(VE1im gt 0) & VE1inst=dblarr(512,512)
VE1inst(kdx) = -2.5*alog10(VE1im(kdx))
;.
idx=where(VE2im gt 0) & VE2inst=dblarr(512,512)
VE2inst(idx) = -2.5*alog10(VE2im(idx))
;.
idx=where(IRCUTim gt 0) & IRCUTinst=dblarr(512,512)
IRCUTinst(idx) = -2.5*alog10(IRCUTim(idx))
;.
BminusV=Vinst*0.0+0.92
;BminusV=0.92
for iter=0,10,1 do begin
V = Vinst + 15.07 - 0.05*(BminusV)
B = Binst + 14.75 + 0.21*(BminusV)
VE1 = VE1inst + 16.30 + 0.18*(BminusV)
VE2 = VE2inst + 13.88 + 1.09*(BminusV)
IRCUT = IRCUTinst + 16.43 + 0.16*(BminusV)
idx=where(Bim gt 0 and Vim gt 0)
BminusV(idx)=B(idx)-V(idx)
;BminusV=mean(B(idx))-mean(V(idx))
print,iter,mean(BminusV(idxBS))
endfor
x0=256
y0=256
get_mask2,x0,y0,radius,mask
BmV=B-V
writefits,'BminusVimage.fits',BmV*mask
writefits,'VE2minusVE1.fits',(VE2-VE1)*mask
NDVI=(VE2-VE1)/(VE2+VE2)
writefits,'NDVI.fits',NDVI*mask
writefits,'maskusd.fits',mask
;
im=BmV*mask
plot,title=VIMname,xstyle=3,ystyle=3,yrange=[0.5,1.1],avg(im(*,226:286),1),xtitle='Column',ytitle='B-V'
plots,[!X.crange],[0.92,0.92],linestyle=2
xyouts,60,1.05,'kB,kV = 0.15, 0.10'
xyouts,60,1.03,'Airmass B = '+string(Bam,format='(f4.2)')
xyouts,60,1.01,'Airmass V = '+string(Vam,format='(f4.2)')
end

