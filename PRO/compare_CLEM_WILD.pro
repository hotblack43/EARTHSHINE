!P.CHARSIZE=2
!P.THICK=3
!x.THICK=3
!y.THICK=3
file='JDsfromCLEM'
openw,55,'CLEM_WILD_albedos.dat'
openr,1,file
ic=0
while not eof(1) do begin
jd=''
readf,1,JD
spawn,"grep "+JD+" CLEM.profiles_fitted_results.txt | awk '{print $1,$2,$3,$4,$5,$6,$7}' > CLEMtoplot"
spawn,"grep "+JD+" WILD.profiles_fitted_results.txt | awk '{print $1,$2,$3,$4,$5,$6,$7}' > WILDtoplot"
;
data=get_data('CLEMtoplot')
clemALB=reform(data(1,*))
errclemALB=reform(data(2,*))
data=get_data('WILDtoplot')
wildALB=reform(data(1,*))
errwildALB=reform(data(2,*))
help,clemALB,wildALB
if (ic eq 0) then plot,xstyle=3,ystyle=3,/nodata,[0.2,0.5],[0.2,0.5],xtitle='CLEM albedos',ytitle='WILD albedos'
oplot,[mean(clemALB),mean(clemALB)],[mean(wildALB),mean(wildALB)],psym=7
oplot,[mean(clemALB),mean(clemALB)],[mean(wildALB)-stddev(wildALB),mean(wildALB)+stddev(wildALB)]
oplot,[mean(clemALB)-stddev(clemALB),mean(clemALB)+stddev(clemALB)],[mean(wildALB),mean(wildALB)]
printf,55,mean(clemALB),mean(errclemALB),mean(wildALB),mean(errwildALB)
ic=ic+1
endwhile
oplot,[!X.crange(0),!x.crange(1)],[!y.crange(0),!y.crange(1)],linestyle=2
close,1
close,55
;
data=get_data('CLEM_WILD_albedos.dat')
histo,data(0,*)-data(2,*),-0.1,0.1,0.001
end
