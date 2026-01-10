close,/all
!P.MULTI=[0,1,1]
file='exposure_scaling_info.dat'
fnames=['_V_'];,'_V_','_VE1_','_VE2_','_IRCUT_']
fname=fnames(0)
spawn,'grep '+fname+' '+file+" | awk '{print $1,$2,$3}' > aha"
data=get_data('aha')
ph=reform(data(0,*))
expt=reform(data(1,*))
maxcount=reform(data(2,*))
want=expt*45000.0/maxcount
plot,abs(ph),expt,xtitle='Lunar phase',ytitle='Exposure time [s]',psym=7
!P.charsize=2
!P.thick=3
!P.charthick=2
xx=(abs(ph))
yy=55000./(maxcount/expt)
idx=sort(xx)
xx=xx(idx)
yy=yy(idx)
idx=where(xx gt 3)
xx=xx(idx)
yy=yy(idx)
xx=[xx,0.0]
yy=[yy,10^(-1.8)]
idx=sort(xx)
xx=xx(idx)
yy=yy(idx)
plot,xx,alog10(yy),xtitle='Lunar phase [0=Full Moon]',ytitle='log!d10!n[t!dexp!n  needed for best flux]',title='Mauna Loa instrument',psym=7
res=poly_fit(xx,alog10(yy),2,yfit=yhat)
res=reform(res)
xx=findgen(181)
yyy=res(0)+res(1)*xx+res(2)*xx^2;+res(3)*xx^3+res(4)*xx^4
yyy(where(xx le 20))=-1.8
t=10^(yyy)
oplot,xx,yyy,color=fsc_color('red')
openw,44,'Scaled_exposure_times_MLO.dat'
t0=mean(t(where(xx le 10)))
plot_io,xx,t/t0,xstyle=3,title='Exposure scaling guide',xtitle='Lunar phase [0 is Full Moon]',ytitle='Exposure time factor'
end
