data=get_data('phase_angles.dat')
!p.thick=5
!x.thick=5
!y.thick=5
!X.style=3
!Y.style=3
!P.charsize=2
!P.charthick=2
histo,/abs,data,-180,180,10,xtitle='Lunar phase angle [Full Moon is 0]'
end
