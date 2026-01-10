JDstart=double(julday(10,31,2009,12,0,0))
JDstop=double(jdstart+31.)
obsJD=double(julday(11,15,2009,15,0,0))

jdstep=.1/24.0d0
obsname='lapalma'
openw,5,'p.dat'
for jd=jdstart,jdstop,jdstep do begin
	mphase,jd, k
	printf,5,format='(2(1x,f20.5),1x,f8.4)', jd,cusp_angle(JD,obsname)/!dtor,k
endfor
close,5
data=get_data('p.dat')
        jd=double(reform(data(0,*)))
        ca=reform(data(1,*))-90.0
illum_frac=reform(data(2,*))
caldat,JDstart,a,b,c,d,e,f
caldat,JDstop,a1,b1,c1,d1,e1,f1
tit=strcompress('From '+string(a)+string(b)+string(c)+string(d)+string(e)+' to '+string(a1)+string(b1)+string(c1)+string(d1)+string(e1))
plot,psym=3,jd-jdSTART,(ca),xtitle='day #',ytitle='Cusp angle',charsize=2,ystyle=1,title=tit,xstyle=1
oplot,jd-jdSTART,(illum_frac-min(illum_frac))/max(illum_frac)*(max(!Y.CRANGE)-min(!Y.CRANGE))+min(!Y.CRANGE),color=fsc_color('blue'),thick=3
plots,[obsJD-JDstart,obsJD-JDstart],[!Y.CRANGE],linestyle=2
res=interpol(ca,jd,obsJD)
print,res
end

