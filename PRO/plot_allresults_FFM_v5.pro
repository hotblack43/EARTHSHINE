!P.MULTI=[0,2,2]
!P.charsize=0.9
!P.THICK=2
!x.THICK=2
!y.THICK=2
for ifil=1,4,1 do begin 
if (ifil eq 1) then begin
	file='allresults_FFM_v5_1p6_93_single_images.txt'
	file='allresults_FFM_v5_1p6_93_single_images_new.txt'
	tstr='!7a!3=1.6. 1 image'
	lleft=-80
	rright=110
endif
if (ifil eq 4) then begin
	file='allresults_FFM_v5_1p8_93_100_images.txt'
	file='allresults_FFM_v5_1p8_93_100_images_new.txt'
	tstr='!7a!3=1.8. 100 co-added images'
	lleft=-100
	rright=100
endif
if (ifil eq 2) then begin
	file='allresults_FFM_v5_1p8_93_single_images.txt'
	file='allresults_FFM_v5_1p8_93_single_images_new.txt'
	tstr='!7a!3=1.8. 1 image'
	lleft=-90
	rright=80
endif
if (ifil eq 3) then begin
	file='allresults_FFM_v5_1p6_93_100_images.txt'
	file='allresults_FFM_v5_1p6_93_100_images_new.txt'
	tstr='!7a!3=1.6. 100 co-added images'
	lleft=-110
	rright=120
endif
data=get_data(file)
offset=reform(data(0,*))
d_offset=reform(data(1,*))
alfa=reform(data(2,*))
d_alfa=reform(data(3,*))
albedo=reform(data(4,*))
d_albedo=reform(data(5,*))
err_im=reform(data(6,*))
err_box=reform(data(7,*))
imnum=reform(data(8,*))
daynum=imnum*9./24.+11.        ; check each time used!
daynum=daynum mod 29.7
phase=daynum*360./29.7-170
pct_d_albedo=d_albedo/albedo*100.0
;
idx=where(abs(phase) gt 10 and abs(phase) lt 120)
true_SSA=0.297
delta_albedo=albedo(idx)-true_SSA
print,'Mean albedo bias: ',mean(delta_albedo),' or ',mean(delta_albedo)/true_SSA*100.,' %.'
print,'Albedo standard deviation: ',stddev(delta_albedo),' or ',stddev(delta_albedo)/true_SSA*100.,' %.'
eps=0.02*true_SSA
plot,title=tstr,xstyle=3,xrange=[-150,150],yrange=[0.290,0.302],phase,albedo,xtitle='Phase [degrees]',ytitle='Fitted SSA',psym=7
;oploterr,phase,albedo,d_albedo
plots,[!X.crange],[true_SSA,true_SSA],linestyle=2
plots,[!X.crange],[true_SSA*1.01,true_SSA*1.01],linestyle=1
plots,[!X.crange],[true_SSA*.99,true_SSA*.99],linestyle=1
plots,[lleft,lleft],[!Y.crange],linestyle=2
plots,[rright,rright],[!Y.crange],linestyle=2
;
;true_offset=400
;plot,title='Single image. !7a!3=1.8',xstyle=3,xrange=[-120,120],yrange=[true_offset+15*stddev(offset),true_offset-15*stddev(offset)],phase,offset,xtitle='Phase [degrees]',ytitle='Offset',psym=7
;oploterr,phase,offset,d_offset
;plots,[!X.crange],[true_offset,true_offset],linestyle=2
;plots,[!X.crange],[true_offset*1.01,true_offset*1.01],linestyle=1
;plots,[!X.crange],[true_offset*.99,true_offset*.99],linestyle=1
;;
;true_offset=1.6
;plot,title='Single image. !7a!3=1.8',xstyle=3,xrange=[-120,120],yrange=[true_offset+15*stddev(alfa),true_offset-15*stddev(alfa)],phase,alfa,xtitle='Phase [degrees]',ytitle='!7a!3',psym=7
;oploterr,phase,alfa,d_alfa
;plots,[!X.crange],[true_offset,true_offset],linestyle=2
;plots,[!X.crange],[true_offset*1.01,true_offset*1.01],linestyle=1
;plots,[!X.crange],[true_offset*.99,true_offset*.99],linestyle=1
endfor
end
