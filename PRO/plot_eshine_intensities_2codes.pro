; first get the output of the analytical code
file='EarthshineseefromMoon.dat'
data=get_data(file)
phase1=reform(data(0,*))
eshineint1Lambert=reform(data(1,*))
eshineint2Lambert=reform(data(2,*))
data=0
!P.MULTI=[0,1,2]
plot,phase1,eshineint1Lambert,xtitle='Phase angle',ytitle='earthshine intensities',xrange=[-179,179],xstyle=1,title='eshine ints from eshine_core (red), analytical solution (thin), Ford code (syms)'
oplot,phase1,eshineint1Lambert,thick=6,color=fsc_color('red')
; then get the output from the IDL integrating code (eshine_core)
file='eshine16out_lambert_lambert.dat'
data=get_data(file)
jd=reform(data(0,*))
Isun=reform(data(1,*))
Iearth=reform(data(2,*))
phase2=reform(data(4,*))
idx=sort(phase2)
phase2=phase2(idx)
Iearth=Iearth(idx)
Iearth_interpolated=INTERPOL(Iearth,phase2,phase1)
;
oplot,phase2,Iearth
; get the eref.out type data for the Lambert case
file='eref.out.lambert.cols2n3'
data=get_data(file)
erefPhase=reform(data(0,*))
erefeshine=reform(data(1,*))/1000.	; mW/m2
oplot,erefPhase,erefeshine,psym=7
; now Ford code Lommel-Seeliger
file='eref.out.lommelseeliger.cols2n3'
data=get_data(file)
erefLSPhase=reform(data(0,*))
erefLSeshine=reform(data(1,*))/1000.	; mW/m2
oplot,erefLSPhase,erefLSeshine,psym=5
; Now plot errors relative to the analytical solution
; first the IDL inetgration
plot_io,phase1,abs(eshineint1Lambert-Iearth_interpolated)/eshineint1Lambert*100.0,xtitle='Phase angle',ytitle='abs intensity differences [%]',xrange=[-179,179],xstyle=1
Forddifference=erefeshine-INTERPOL(eshineint1Lambert,phase1,erefPhase)
oplot,erefPhase,abs(Forddifference/INTERPOL(eshineint1Lambert,phase1,erefPhase)*100.),psym=7
end
