in=readfits('ideal_starting_image.fit')
cons=readfits('simulated_observed_image.fit')
out=readfits('corrected_image.fit')
;--------------------------------
factor=mean(out)/mean(in)
in=in*factor
diff=(out-in)
ratio=out/in
pct=diff/in*100.0
width=100	; rebin size
!P.multi=[0,1,2]
surface,rebin(in,width,width),/zlog,title='Ideal image input',charsize=2,ystyle=1
surface,rebin(out,width,width),/zlog,title='Cleaned-up image output',charsize=2,ystyle=1
surface,rebin(diff,width,width),/zlog,title='abs(OUT-IN)',charsize=2,ystyle=1
;surface,rebin(subt,width,width),/zlog,title='Last correction for scattered light',charsize=2,ystyle=1
surface,rebin(ratio,width,width),/ZLOG,title='OUT/IN',charsize=2,ystyle=1
surface,rebin(in,width,width),title='Ideal image input',charsize=2,ystyle=1
surface,rebin(out,width,width),title='Cleaned-up image output',charsize=2,ystyle=1
surface,rebin(diff,width,width),title='abs(OUT-IN)',charsize=2,ystyle=1
;surface,rebin(subt,width,width),title='Last correction for scattered light',charsize=2,ystyle=1
surface,rebin(ratio,width,width),title='OUT/IN',charsize=2,ystyle=1
!P.MULTI=[0,2,3]
plot,in(*,200),/ylog,yrange=[max(in(*,200))/1e4,max(in(*,200))],ystyle=1,charsize=2,ytitle='Input image, row 200',xstyle=1
plot,out(*,200),/ylog,yrange=[max(out(*,200))/1e4,max(out(*,200))],ystyle=1,charsize=2,ytitle='Cleaned-up image, row 200',xstyle=1
plot,cons(*,200),/ylog,yrange=[max(cons(*,200))/1e4,max(cons(*,200))],ystyle=1,charsize=2,ytitle='Constructed image, row 200',xstyle=1
plot,diff(*,200),/ylog,yrange=[max(diff(*,200))/1e4,max(diff(*,200))],ystyle=1,charsize=2,ytitle='(|OUT-IN| image, row 200',xstyle=1
;plot,subt(*,200),/ylog,yrange=[max(subt(*,200))/1e4,max(subt(*,200))],ystyle=1,charsize=2,ytitle='Last subtracted image, row 200',xstyle=1
plot,ratio(*,200),/ylog,yrange=[max(ratio(*,200))/1e4,max(ratio(*,200))],ystyle=1,charsize=2,ytitle='OUT/IN image, row 200',xstyle=1
plot,ratio(*,200),yrange=[max(ratio(*,200))/1e4,max(ratio(*,200))],ystyle=1,charsize=2,ytitle='OUT/IN image, row 200',xstyle=1
; regions
out_dark=out(14:189,166:227)
out_brig=out(265:269,184:218)
in_dark=in(14:189,166:227)
in_brig=in(265:269,184:218)
print,'# of pixels in out_dark:',n_elements(out_dark)
print,'# of pixels in out_brig:',n_elements(out_brig)
print,'# of pixels in in_dark:',n_elements(in_dark)
print,'# of pixels in in_brig:',n_elements(in_brig)

rin=mean(in_dark)/mean(in_brig)
rout=mean(out_dark)/mean(out_brig)
print,mean(in_dark),mean(in_brig),mean(out_dark),mean(out_brig)
print,'DB ratio input image:',rin
print,'DB ratio output image:',rout
print,'ratio of DB ratios:',rin/rout
print,'% change in DB ratios:',(rout-rin)/((0.5*(rout+rin)))*100.0
;
!P.MULTI=[0,1,2]
;contour,in,/zlog,/cell_fill,nlevels=101,/isotropic,title='Ideal in'
;contour,out,/zlog,/cell_fill,nlevels=101,/isotropic,title='Corrected'
surface,diff,charsize=2,title='Corrected - In'
surface,rebin(abs(diff/in),100,100),/zlog,charsize=2,title='(Corrected - In)/In'
end
