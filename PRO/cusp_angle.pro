FUNCTION cusp_angle,JD,obsname

;-----------------------------------------------------------------------
; JD (INOUT) Julian day of observation time
; obsname (INPUT) Name of observing stations - see "observatory.pro"
; chi (OUTPUT) Cusp angle in radians, returned in function name
;-----------------------------------------------------------------------
;   alpha, delta = right ascension, declination of moon 
;   alpha0, delta0 = right ascension, declination of sun
;   chi = position angle of the midpoint of the illuminated limb (measured eastward from north)

MOONPOS, jd, alpha, delta, dis
SUNPOS, jd, alpha0, delta0

alpha=alpha*!dtor
alpha0=alpha0*!dtor
delta=delta*!dtor
delta0=delta0*!dtor

tanchi = [ cos(delta0) * sin(alpha0 - alpha) ] / [ sin(delta0) * cos(delta) - cos(delta0) * sin(delta) * cos(alpha0 - alpha) ] 

chi=atan(cos(delta0) * sin(alpha0 - alpha),sin(delta0) * cos(delta) - cos(delta0) * sin(delta) * cos(alpha0 - alpha))

;print,jd,alpha, delta,alpha0, delta0
return,chi
end

JDstart=double(julday(7,1,2010,0,0,0))
JDstop=double(jdstart+370.)
obsJD=julday(12,7,1997,22,0,0)
jdstep=1.
obsname='lapalma'
openw,5,'p.dat'
for jd=jdstart,jdstop,jdstep do begin
	mphase,jd, k
	printf,5,format='(2(1x,f20.5),1x,f8.4)', jd,cusp_angle(JD,obsname)/!dtor,k
endfor
close,5
data=get_data('p.dat')
        jd=reform(data(0,*))
        ca=reform(data(1,*))
illum_frac=reform(data(2,*))
caldat,JDstart,a,b,c,d,e,f
caldat,JDstop,a1,b1,c1,d1,e1,f1
tit=strcompress('From '+string(a)+string(b)+string(c)+string(d)+string(e)+' to '+string(a1)+string(b1)+string(c1)+string(d1)+string(e1))
plot,psym=3,jd-jdSTART,(ca),xtitle='day #',ytitle='Cusp angle',charsize=2,ystyle=1,title=tit,xstyle=1
oplot,jd-jdSTART,(illum_frac-min(illum_frac))/max(illum_frac)*(max(!Y.CRANGE)-min(!Y.CRANGE))+min(!Y.CRANGE),color=fsc_color('blue'),thick=3
plots,[obsJD-JDstart,obsJD-JDstart],[!Y.CRANGE],linestyle=2
end
