















!P.charsize=2
!P.thick=3
!P.charthick=2
!P.MULTI=[0,1,2]
data=get_data('dsbsratio.dat')
tstr='Black:BBSO, Red:Ideal, Green:Halo'
plot,yrange=[0,2.5e-4],title=tstr,data(1,*),data(4,*),psym=1,xtitle='Lunar phase angle',ytitle='DS/BS'
oplot,data(1,*),data(3,*),psym=2,color=fsc_color('red')
oplot,data(1,*),data(2,*),psym=7,color=fsc_color('green')
;-------
plot,yrange=[1,2.6],title='Red:BBSO, Black:Halo',ystyle=3,data(1,*),data(6,*),psym=7,xtitle='Lunar phase angle',ytitle='(BBSO or Halo)/Ideal'
oplot,data(1,*),data(5,*),color=fsc_color('red'),psym=1
oplot,[!X.crange],[1,1],linestyle=2
end
