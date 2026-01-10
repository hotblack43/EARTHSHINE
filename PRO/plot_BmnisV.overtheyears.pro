data=get_data('BmnisV.overtheyears')
year=reform(data(0,*))
BmB=reform(data(1,*))
errBmB=reform(data(2,*))
;
!P.CHARSIZE=1.6
plot,yrange=[-1,0],year,BmB,psym=7,xtitle='Year',ytitle='!7D!3(B-V)!dDS-BS!n'
oploterr,year,BmB,errBmB
xyouts,/normal,0.22,0.465,'Danjon'
xyouts,/normal,0.47,0.7,'Franklin'
xyouts,/normal,0.77,0.73,'This work'
end
