; code to analyse how the ND filters should be chosen
;
; first read in the simulated BS to DS ratio - it was output by eshine_16.pro
file='simulated_BSDSratios.dat'
data=get_data(file)
jd=reform(data(0,*))
ph=reform(data(1,*))
ratio=reform(data(2,*))
; selct for the useful phases
idx=where(abs(ph) gt 40 and abs(ph) lt 145)
jd=jd(idx)
ph=ph(idx)
ratio=ratio(idx)
ratio=ratio*1.25	; empirical scaling due to 3 data points
openw,11,'ratio.dat'
for i=0,n_elements(ratio)-1,1 do begin
    if (ratio(i) gt 1.) then printf,11,jd(i)-jd(0),ratio(i)
    endfor
close,11
 data=get_data('ratio.dat')
 d=reform(data(0,*))
 r=reform(data(1,*))
 !P.MULTI=[0,1,3]
 plot_io,d,r,xtitle='day # [arb offset]',ytitle='unfiltered BS/ES ratio',charsize=2,psym=-7
 ; define the filters and some limits

 lim1=1e10 & lim2=10^4.5
 idx=where(r lt lim1 and r ge lim2)
 f1=10^mean(alog10(r(idx)))

 lim3=lim2 & lim4=10^3.9
 idx=where(r lt lim3 and r ge lim4)
 f2=10^mean(alog10(r(idx)))

 lim5=lim4 & lim6=10^3.5
 idx=where(r lt lim5 and r ge lim6)
 f3=10^mean(alog10(r(idx)))
; brute force
;	f1=10^4.0
;	f2=10^3.75
;	f3=10^3.5
 openw,12,'filtered_ratio.dat'
 for i=0,n_elements(d)-1,1 do begin
     if (r(i) le lim1 and r(i) ge lim2) then printf,12,d(i),r(i)/f1
     if (r(i) le lim3 and r(i) ge lim4) then printf,12,d(i),r(i)/f2
     if (r(i) le lim5 and r(i) ge lim6) then printf,12,d(i),r(i)/f3
     endfor
 close,12
 data=get_data('filtered_ratio.dat')
 xx=reform(data(0,*))
 yy=reform(data(1,*))
 plot_io,xx,yy,xtitle='day # [arb offset]',ytitle='filtered BS/ES ratio',charsize=2,psym=7
 plots,[!X.crange],[1,1],linestyle=2
 !P.charsize=1.2
fOD=1.5
xpos=(max(!x.crange)-min(!x.crange))*0.7+min(!x.crange)
ypos=(max(!y.crange)-min(!y.crange))*0.9+min(!y.crange)
 xyouts,/data,xpos,60,strcompress('OD1= '+strmid(string(fOD),0,9)+' + '+ strmid(string(alog10(f1)-fOD),0,11)+' = '+strmid(string(alog10(f1)),0,11))
 xyouts,/data,xpos,30,strcompress('OD2= '+strmid(string(fOD),0,9)+ ' + '+strmid(string(alog10(f2)-fOD),0,11)+' = '+strmid(string(alog10(f2)),0,11))
 xyouts,/data,xpos,10,strcompress('OD3= '+strmid(string(fOD),0,9)+ ' + '+strmid(string(alog10(f3)-fOD),0,11)+' = '+strmid(string(alog10(f3)),0,11))
 ;
 !P.charsize=2
 histo,yy,0,max(yy)*1.05,0.1,xtitle='Filtered BS/ES ratio',ytitle='N'
 end
