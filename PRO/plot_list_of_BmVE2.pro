data=get_data('List_of_BmVE2_.dat')
jd=reform(data(0,*))
ph=reform(data(1,*))
fl1=reform(data(2,*))
fl2=reform(data(3,*))
BmVE2=reform(data(4,*))
!P.MULTI=[0,2,2]
!P.CHARSIZE=2
yr=[min(BmVE2),max(BmVE2)]
;---------------------
idx=where(fl1 eq 1 and fl2 eq 1)
plot,ystyle=3,yrange=yr,xstyle=3,title='Both in BS',ph(idx),BmVE2(idx),psym=7,xtitle='Lunar Phase',ytitle='!7D!3(B-VE2)'
oplot,[!X.CRANGE],[median(BmVE2(idx)),median(BmVE2(idx))]
plot,xstyle=3,ystyle=3,psym=7,jd(idx) mod 1,BmVE2(idx),xtitle='Time of day [fr. day]',ytitle='B-VE2',title='Both in BS'


;---------------------
jdx=where(fl1 eq 2 and fl2 eq 2)
plot,ystyle=3,yrange=yr,xstyle=3,title='Both in DS',ph(jdx),BmVE2(jdx),psym=7,xtitle='Lunar Phase',ytitle='!7D!3(B-VE2)'
oplot,[!X.CRANGE],[median(BmVE2(jdx)),median(BmVE2(jdx))]
plot,xstyle=3,ystyle=3,psym=7,jd(jdx) mod 1,BmVE2(jdx),xtitle='Time of day [fr. day]',ytitle='B-VE2',title='Both in DS'
;.............................
print,'median B-VE2 BS minus median B-VE2 DS: ',median(BmVE2(idx))-median(BmVE2(jdx))
end
