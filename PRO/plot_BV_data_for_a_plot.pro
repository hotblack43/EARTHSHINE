str='B'
spawn,'grep '+str+" BV_data_for_a_plot.dat | awk '{print $2}' > block.dat"
B=get_data('block.dat')
str='"V "'
spawn,'grep '+str+" BV_data_for_a_plot.dat | awk '{print $2}' > block.dat"
V=get_data('block.dat')
str='VE1'
spawn,'grep '+str+" BV_data_for_a_plot.dat | awk '{print $2}' > block.dat"
VE1=get_data('block.dat')
str='VE2'
spawn,'grep '+str+" BV_data_for_a_plot.dat | awk '{print $2}' > block.dat"
VE2=get_data('block.dat')
str='IRCUT'
spawn,'grep '+str+" BV_data_for_a_plot.dat | awk '{print $2}' > block.dat"
IRCUT=get_data('block.dat')
;
help
data=[B,V,VE1,VE2,IRCUT]
data=5-2.5*alog10(data)
!P.CHARSIZE=1.4
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.CHARTHICK=2
!x.tickname=['B','V','VE1','VE2','IRCUT']
plot,ytitle='DS relative to BS [magnitudes]',xstyle=3,[1,2,3,4,5],data(*,0),psym=7,yrange=[max(data),min(data)],ystyle=3	; EFM night 1
oplot,[1,2,3,4,5],data(*,1),psym=6	; BBSO night 1
offset=0.0; -0.51
oplot,[1,2,3,4,5],data(*,2)+offset,psym=7;,color=fsc_color('red')	; EFM night 2
oplot,[1,2,3,4,5],data(*,3)+offset,psym=6;,color=fsc_color('red')	; BBSO night 2
xyouts,/normal,0.5,0.3,'JD 2455858'
xyouts,/normal,0.5,0.7,'JD 2455917'
end
