data=get_data('List_of_BmV_.dat')
jd=reform(data(0,*))
ph=reform(data(1,*))
fl1=reform(data(2,*))
fl2=reform(data(3,*))
BmV=reform(data(4,*))
!P.MULTI=[0,2,2]
!P.CHARSIZE=2
yr=[min(BmV),max(BmV)]
;---------------------
idx=where(fl1 eq 1 and fl2 eq 1)
plot,ystyle=3,yrange=yr,xstyle=3,title='Both in BS',ph(idx),BmV(idx),psym=7,xtitle='Lunar Pjhase',ytitle='!7D!3(B-V)'
oplot,[!X.CRANGE],[median(BmV(idx)),median(BmV(idx))]
plot,xstyle=3,ystyle=3,psym=7,jd(idx) mod 1,BmV(idx),xtitle='Time of day [fr. day]',ytitle='B-V',title='Both in BS'


;---------------------
jdx=where(fl1 eq 2 and fl2 eq 2)
plot,ystyle=3,yrange=yr,xstyle=3,title='Both in DS',ph(jdx),BmV(jdx),psym=7,xtitle='Lunar Pjhase',ytitle='!7D!3(B-V)'
oplot,[!X.CRANGE],[median(BmV(jdx)),median(BmV(jdx))]
plot,xstyle=3,ystyle=3,psym=7,jd(jdx) mod 1,BmV(jdx),xtitle='Time of day [fr. day]',ytitle='B-V',title='Both in DS'
;.............................
print,'median B-V BS minus median B-V DS: ',median(BmV(idx))-median(BmV(jdx))
end
