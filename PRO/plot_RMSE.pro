colname=['black','red','green','blue','black']
!P.CHARSIZE=1.3
!P.THICK=3
!X.thick=2
!y.thick=2
openr,1,'CLEMfiles'
ic=0
while not eof(1) do begin
nam=''
readf,1,nam
spawn,'cat '+nam+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8}' > pjhgfdc.dat"
data=get_data('pjhgfdc.dat')
RMSE=reform(data(6,*))
stat=alog10(RMSE)
!P.COLOR=fsc_color(colname(ic))
if (ic eq 0) then histo,stat,-2,2,0.02,xtitle='log!d10!n of RMSE'
histo,stat,-2,2,0.02,/overplot
xyouts,/normal,0.4,0.90-ic*0.03,nam,charsize=0.8
ic=ic+1
print,'Median RMSE: ',10^mean(stat),nam
endwhile
close,1
end
