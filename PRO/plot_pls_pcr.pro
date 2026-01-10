
data=read_ascii("c:\RSI\WORK\R_example1_outliers_removed.txt")
order=data.field1(0,*)
pls=data.field1(1,*)
pcr=data.field1(2,*)
plot,order,pls,linestyle=0,xtitle='n',ytitle='STD of test residuals',ystyle=1,yrange=[0.7,0.9],psym=-4
oplot,order,pcr,linestyle=2,psym=-4
;plots,[!X.CRANGE],[1.1,1.1],linestyle=3

end