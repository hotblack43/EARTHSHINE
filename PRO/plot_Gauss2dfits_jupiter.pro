file='fits_JUPITER.dat'
file='fits_ALTAIR.dat'
spawn,"awk '{print $1,$10,$2}' "+file+" > aha"
data=get_data('aha')
!P.MULTI=[0,1,2]
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
idx=where(data(1,*) eq 0)
plot,xstyle=3,ystyle=3,data(1,*),data(2,*),ytitle='Sky level',psym=7,xtitle='Filter #'
idx=where(data(1,*) eq 1)
oplot,data(1,idx),data(2,idx),psym=7,color=fsc_color('red')
idx=where(data(1,*) eq 2)
oplot,data(1,idx),data(2,idx),psym=7,color=fsc_color('blue')
idx=where(data(1,*) eq 3)
oplot,data(1,idx),data(2,idx),psym=7,color=fsc_color('orange')
idx=where(data(1,*) eq 4)
oplot,data(1,idx),data(2,idx),psym=7,color=fsc_color('green')
idx=where(data(1,*) eq 0)
plot,xstyle=3,ystyle=3,data(0,*) mod 1,data(2,*),ytitle='Sky level',psym=7
idx=where(data(1,*) eq 1)
oplot,data(0,idx) mod 1,data(2,idx),psym=7,color=fsc_color('red')
idx=where(data(1,*) eq 2)
oplot,data(0,idx) mod 1,data(2,idx),psym=7,color=fsc_color('blue')
idx=where(data(1,*) eq 3)
oplot,data(0,idx) mod 1,data(2,idx),psym=7,color=fsc_color('orange')
idx=where(data(1,*) eq 4)
oplot,data(0,idx) mod 1,data(2,idx),psym=7,color=fsc_color('green')
end
;     396.549      55739.8      2.21515      2.02768      316.399      264.493 -0.378803 _B_
