im=readfits('ideal_used_for_slope_studies.fits')
writefits,'source.fits',im
; fold it
ic=0
!P.CHARSIZE=1.2
!P.thick=3
!x.thick=3
!y.thick=3
for alfa=1.8,1.4,-.1 do begin
str='./justconvolve source.fits source_folded_out.fits '+string(alfa)
spawn,str
fim=readfits(/silent,'source_folded_out.fits')
if (ic eq 0) then plot_io,fim(*,256),xstyle=3,ystyle=3
if (ic gt 0) then oplot,fim(*,256)
oplot,im(*,256),color=fsc_color('red')
x=[10.,50.,80.]
y=[fim(10,256),fim(50,256),fim(80,256)]
res=linfit(x,y,yfit=yhat)
x=findgen(200)
yhat=res(0)+res(1)*x
print,alfa,res(1)
oplot,x,yhat,color=fsc_color('green')
xyouts,210,yhat(199),'!7a!3, slope: '+string(alfa,format='(f3.1)')+' / '+string(res(1),format='(f7.5)')
ic=ic+1
endfor
; other plot, jyust at edge
ic=0
for alfa=1.8,1.4,-.1 do begin
str='./justconvolve source.fits source_folded_out.fits '+string(alfa)
spawn,str
fim=readfits(/silent,'source_folded_out.fits')
if (ic eq 0) then plot_io,fim(*,256),xstyle=3,ystyle=3,xrange=[110,120]
if (ic gt 0) then oplot,fim(*,256)
oplot,im(*,256),color=fsc_color('red')
x=[10.,50.,80.]
y=[fim(10,256),fim(50,256),fim(80,256)]
res=linfit(x,y,yfit=yhat)
x=findgen(200)
yhat=res(0)+res(1)*x
print,alfa,res(1)
xyouts,210,yhat(199),'!7a!3, slope: '+string(alfa,format='(f3.1)')+' / '+string(res(1),format='(f7.5)')
ic=ic+1
endfor
end

