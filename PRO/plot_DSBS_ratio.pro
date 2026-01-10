file='DSBS_ratio.dat'
data=get_data(file)
phase=reform(data(0,*))
ratio_InSpace=reform(data(1,*))
ratio_Observed=reform(data(2,*))
ratio_Cleaned=reform(data(3,*))
ratio_BBSO=reform(data(4,*))
average=reform(data(5,*))
; count winners
cleaned_err=(ratio_Cleaned-ratio_InSpace)/ratio_InSpace*100.0
BBSO_err=(ratio_BBSO-ratio_InSpace)/ratio_InSpace*100.0
BLIND_err=(ratio_Cleaned-ratio_InSpace)/ratio_InSpace*100.0
bbwins=0
bdwins=0
for ip=0,n_elements(phase)-1,1 do begin
if (abs(phase(ip)) ge 40 and abs(phase(iP)) le 140) then begin
if ((abs(bbso_err(ip)) lt abs(BLIND_err(ip))) eq 1) then bbwins=bbwins+1
if ((abs(bbso_err(ip)) gt abs(BLIND_err(ip))) eq 1) then bdwins=bdwins+1
endif
endfor
print,'BD wins ',bdwins,' times.'
print,'BBSO wins ',bbwins,' times.'

;device,/landscape,/color
!P.CHARSIZE=1.3
!P.THICK=2
!x.THICK=2
!y.THICK=2
idx=where(phase gt 0)
openr,23,'message.txt'
str=''
readf,23,str
close,23
plot_io,phase(idx),ratio_InSpace(idx),title='Space: Plus, Observed:diamonds, Cleaned: triangles, BBSO:squares',psym=1,xtitle='Lunar Phase angle (S-M-E)',ytitle='BS/DS',yrange=[1,1e6],subtitle=str
oplot,phase(idx),ratio_InSpace(idx),psym=1,color=fsc_color('red')
oplot,phase(idx),ratio_Observed(idx),psym=4,color=fsc_color('red')
oplot,phase(idx),ratio_Cleaned(idx),psym=5,color=fsc_color('red')
oplot,phase(idx),ratio_BBSO(idx),psym=6,color=fsc_color('red')
idx=where(phase le 0)
oplot,abs(phase(idx)),1./ratio_InSpace(idx),psym=1,color=fsc_color('blue')
oplot,abs(phase(idx)),1./ratio_Observed(idx),psym=4,color=fsc_color('blue')
oplot,abs(phase(idx)),1./ratio_Cleaned(idx),psym=5,color=fsc_color('blue')
oplot,abs(phase(idx)),1./ratio_BBSO(idx),psym=6,color=fsc_color('blue')
;
plots,[40,40],[1,1e4],linestyle=2
plots,[140,140],[1,1e4],linestyle=2
;device,/close
; plot the BS data only
; idx=where(average gt 4000)
; plot the DS data only
idx=where(average lt 4000)
;'Space: Plus, Observed:diamonds, Cleaned: triangles, BBSO:squares'
plot,phase(idx),(ratio_Observed(idx)-ratio_InSpace(idx))/ratio_InSpace(idx)*100.0,psym=4,title='BS only: 2 patches. Diamonds= Obs., Boxes=BBSO, Triangles=Cleaned',xtitle='Lunar phase',ytitle='BS1/BS2 rel err [%]',charsize=0.9
oplot,phase(idx),(ratio_Cleaned(idx)-ratio_InSpace(idx))/ratio_InSpace(idx)*100.0,psym=5
oplot,phase(idx),(ratio_BBSO(idx)-ratio_InSpace(idx))/ratio_InSpace(idx)*100.0,psym=6
plots,[!X.CRANGE],[0,0],linestyle=2
end

