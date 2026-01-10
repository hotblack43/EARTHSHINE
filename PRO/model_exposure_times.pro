PRO plotfilter,x0,w,txt
common fill,angle_count
plots,[x0-w/2.,x0-w/2.],[.0001,10.]
plots,[x0+w/2.,x0+w/2.],[.0001,10.]
xyouts,x0-w/4.,2,txt
polyfill,[x0-w/2.,x0-w/2.,x0+w/2.,x0+w/2.,x0-w/2.],[!Y.CRANGE(0),!Y.CRANGE(1),!Y.CRANGE(1),!Y.CRANGE(0),!Y.CRANGE(0)],/line_fill,orientation=45+90*angle_count
angle_count=angle_count+1
return
end

PRO get_UBV,xx,yy,U,B,V,R,I,J,K,L
zz=yy
; U
x0=365.
w=68.
plotfilter,x0,w,'U'
idx=where(xx gt x0-w/2. and xx lt x0+w/2.)
U=int_tabulated(xx(idx),yy(idx))
yy=zz
; B
x0=440.
w=98.
plotfilter,x0,w,'B'
idx=where(xx gt x0-w/2. and xx lt x0+w/2.)
B=int_tabulated(xx(idx),yy(idx))
yy=zz
; V
x0=550.
w=89.
plotfilter,x0,w,'V'
idx=where(xx gt x0-w/2. and xx lt x0+w/2.)
V=int_tabulated(xx(idx),yy(idx))
yy=zz
; R
x0=700.
w=220.
plotfilter,x0,w,'R'
idx=where(xx gt x0-w/2. and xx lt x0+w/2.)
R=int_tabulated(xx(idx),yy(idx))
yy=zz
; I
x0=900.
w=240.
plotfilter,x0,w,'I'
idx=where(xx gt x0-w/2. and xx lt x0+w/2.)
I=int_tabulated(xx(idx),yy(idx))
yy=zz
; J
x0=1250.
w=380.
idx=where(xx gt x0-w/2. and xx lt x0+w/2.)
J=int_tabulated(xx(idx),yy(idx))
yy=zz
; K
x0=2200.
w=480.
idx=where(xx gt x0-w/2. and xx lt x0+w/2.)
K=int_tabulated(xx(idx),yy(idx))
yy=zz
; L
x0=3400.
w=700.
idx=where(xx gt x0-w/2. and xx lt x0+w/2.)
L=int_tabulated(xx(idx),yy(idx))
yy=zz
return
end

PRO get_uvby,xx,yy,u,v,b,y
; applies STromgren filtesr to the wavelength vs. flux table
; u
zz=yy
x0=350.
w=34.
idx=where(xx gt x0-w/2. and xx lt x0+w/2.)
u=int_tabulated(xx(idx),yy(idx))
yy=zz
; v
x0=411.
w=20.
idx=where(xx gt x0-w/2. and xx lt x0+w/2.)
v=int_tabulated(xx(idx),yy(idx))
yy=zz
; b
x0=467.
w=16.
idx=where(xx gt x0-w/2. and xx lt x0+w/2.)
b=int_tabulated(xx(idx),yy(idx))
yy=zz
; y
x0=547.
w=24.
;
idx=where(xx gt x0-w/2. and xx lt x0+w/2.)
y=int_tabulated(xx(idx),yy(idx))
return
end


PRO get_CCD_QE,nm_in,QE
common dirs,dir
; will return the CCD Quantum Efficiency given wavelength in nm
common flags,flag_solar,flag_atmtrans,flags_CCDQE
common CCDQE,x,y
if (flags_CCDQE ne 314) then begin
flags_CCDQE=314

; for CCD_QE_KAF1001E.txt
file=dir+'CCD_QE_KAF1001E.txt'
data=get_data(file)
x=reform(data(0,*))
y=reform(data(2,*))
file=dir+'CCD_QE.txt'
data=get_data(file)
x=reform(data(0,*))
y=reform(data(1,*))
plot,x,y,xtitle='Wavelength (nm)',ytitle='CCD Q.E.',charsize=1.5,xrange=[200,1200]
endif
QE=interpol(y,x,nm_in)
if (nm_in lt min(x) or nm_in gt max(x)) then QE=0.0
return
end

PRO get_solar_flux,nm_in,fluxout
common dirs,dir
; will return the Wherli 1985 solar flux (in W(nm)) given wavelength (in nm) as input
common flags,flag_solar,flag_atmtrans,flags_CCDQE
common wherli,x,y,z
if (flag_solar ne 314) then begin
flag_solar=314
;file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\wehrli85.txt'
file=dir+'wehrli85.txt'
data=get_data(file)
x=reform(data(0,*))
y=reform(data(1,*))
;z=reform(data(2,*))
plot,x,y,xtitle='Wavelength (nm)',ytitle='Wehrli 85 Solar flux',title='Composite curve',charsize=1.5,xrange=[200,1200],xstyle=1

endif
fluxout=interpol(y,x,nm_in)
if (nm_in lt min(x) or nm_in gt max(x)) then fluxout=0.0
return
end

PRO get_atmospheric_transmission,nm_in,transout
common dirs,dir
; will return the atmospheric transmission coefficient
common flags,flag_solar,flag_atmtrans,flags_CCDQE
common atmtrans,x,y
if (flag_atmtrans ne 314) then begin
flag_atmtrans=314
file=dir+'atm_trans.txt'
;file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\atm_trans.txt'
data=get_data(file)
x=reform(data(0,*))
y=10^(reform(data(1,*))/(-2.5))
idx=where(x lt 900)
x=x(idx)
y=y(idx)
; get detailed ATRAN curve and paste it on after 900 nm
file=dir+'trans_30_10.dat'
data=get_data(file)
x2=reform(data(0,*))*1000.0
y2=reform(data(1,*))
idx=where(x2 gt 900)
x=[x,x2(idx)]
y=[y,y2(idx)]
plot,x,y,xtitle='Wavelength (nm)',ytitle='Atmospheric transmission',charsize=1.5,xrange=[200,1200]
endif
transout=interpol(y,x,nm_in)
if (nm_in lt min(x) or nm_in gt max(x)) then transout=0.0
return
end

common flags,flag_solar,flag_atmtrans,flags_CCDQE
common fill,angle_count
common dirs,dir
;-----------------------------------------------
dir='./'
!P.MULTI=[0,1,4]
flag_solar=1
flag_atmtrans=1
flags_CCDQE=1
angle_count=1
xx=fltarr(10000)
yy=fltarr(10000)
i=0
for nm_in=150,4200,2 do begin
    get_solar_flux,nm_in,fluxout
    get_atmospheric_transmission,nm_in,transout
    get_CCD_QE,nm_in,QE
    xx(i)=nm_in
    yy(i)=fluxout*transout*QE
    ;print,nm_in,fluxout,transout,QE
i=i+1
endfor
idx=where(yy ne 0.0)

plot,xx(idx),yy(idx),xtitle='Wavelength (nm)',ytitle='Throughput',charsize=1.6,xrange=[200,1200]
get_uvby,xx,yy,u,v,b,y
print,format='(a,4(1x,f8.2))','Strömgren uvby fluxes:',u,v,b,y
print,format='(a,4(1x,f8.2))',' obstime relative to y: ',1./(u/y),1./(v/y),1./(b/y),1./(y/y)
get_UBV,xx,yy,U,B,V,R,I,J,K,L
print,format='(a,8(1x,f8.2))','Johnson fluxes:',U,B,V,R,I,J,K,L
print,format='(a,8(1x,f8.2))',' obstime relative to R:',R/U,R/B,R/V,R/R,R/I,R/J,R/K,R/L
end
