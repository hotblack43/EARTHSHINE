data=get_data('slopes.dat')
!P.multi=[0,2,2]
!P.THICK=3
!P.charsize=1.3
!P.charthick=2
!P.multi=[0,2,3]
histo,data(0,*),min(data(0,*)),max(data(0,*)),(max(data(0,*))-min(data(0,*)))/18.,/abs,xtitle='Slope in albedo(alfa)'
oplot,[0,0],[!Y.crange],linestyle=1
histo,data(1,*),min(data(1,*)),max(data(1,*)),(max(data(1,*))-min(data(1,*)))/18.,/abs,xtitle='Slope in albedo(ped)'
oplot,[0,0],[!Y.crange],linestyle=1
histo,data(2,*),min(data(2,*)),max(data(2,*)),(max(data(2,*))-min(data(2,*)))/13.,/abs,xtitle='Slope in albedo(dx)'
oplot,[0,0],[!Y.crange],linestyle=1
histo,data(3,*),min(data(3,*)),max(data(3,*)),(max(data(3,*))-min(data(3,*)))/13.,/abs,xtitle='Slope in albedo(dy)'
oplot,[0,0],[!Y.crange],linestyle=1
xyouts,/normal,0.25,1.01,'Slopes of Albedo agaisnt parameters'
end
