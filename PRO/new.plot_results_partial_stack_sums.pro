PRO goplot,istyle,x,y,boot_x,boot_y,xtitstr,ytitstr,tstr,othercolor,yran
csize=1.4
; istyle=1 implies lin-lin plot
; istyle=2 implies log-lin plot
; istyle=3 implies log-lin plot but no regression lines plotted
common legendpos,x1,y1,x2,y2

if (istyle eq 1) then plot,title=tstr,yrange=yran,xstyle=3,ystyle=3,x,y,psym=7,xtitle=xtitstr,ytitle=ytitstr
if (istyle eq 2 or istyle eq 3) then plot_oi,title=tstr,yrange=yran,xstyle=3,ystyle=3,x,y,psym=7,xtitle=xtitstr,ytitle=ytitstr
res=ladfit((x),(y))
yhat=res(0)+res(1)*(x)
if (istyle ne 3) then oplot,x,yhat,color=fsc_color('red')
if (istyle ne 3) then xyouts,/data,x1,y1,'Slope: '+string(res(1),format='(f7.2)'),charsize=csize
oplot,boot_x,boot_y,psym=7,color=othercolor
boot_res=ladfit((boot_x),(boot_y))
boot_yhat=boot_res(0)+boot_res(1)*(boot_x)
if (istyle ne 3) then oplot,boot_x,boot_yhat,color=othercolor
if (istyle ne 3) then xyouts,/data,x2,y2,'b Slope: '+string(boot_res(1),format='(f7.2)'),charsize=csize
return
end

;------------------------------------------------------

;    70 aligned integershift
;    70 aligned subpixelshift
;    70 unaligned sum

common legendpos,x1,y1,x2,y2
CLEMfile='CLEM.tests.2456073.7983881'
CLEMfile='CLEM.testing_sep26_2014.txt'
file=CLEMfile
spawn,"grep sum_of "+file+" |  grep unaligned | awk '{print $2,$3,$11,$15}' > aha"
spawn,"awk '{print $4}' aha | sed 's/_/ /g' | awk '{print $7}' > oho"
spawn,"awk '{print $1,$2,$3}' aha > jaja"
spawn,"paste jaja oho > data_unaligned.dat"
data=get_data('data_unaligned.dat')
albedo=reform(data(0,*))
delta_albedo=alog10(reform(data(1,*)))
RMSE=alog10(reform(data(2,*)))
nframes=alog10(reform(data(3,*)))

file=CLEMfile
spawn,"grep sum_of "+file+" | grep aligned | grep integershift |  awk '{print $2,$3,$11,$15}' > aha"
spawn,"awk '{print $4}' aha | sed 's/_/ /g' | awk '{print $(NF-3)}'  > oho"
spawn,"awk '{print $1,$2,$3}' aha > jaja"
spawn,"paste jaja oho > data_aligned_intshift.dat"
intshift_data=get_data('data_aligned_intshift.dat')
boot_albedo=reform(intshift_data(0,*))
boot_delta_albedo=alog10(reform(intshift_data(1,*)))
boot_RMSE=alog10(reform(intshift_data(2,*)))
boot_nframes=alog10(reform(intshift_data(3,*)))

file=CLEMfile
spawn,"grep sum_of "+file+" | grep aligned | grep subpixelshift| awk '{print $2,$3,$11,$15}' > aha"
spawn,"awk '{print $4}' aha | sed 's/_/ /g' | awk '{print $(NF-3)}'  > oho"
spawn,"awk '{print $1,$2,$3}' aha > jaja"
spawn,"paste jaja oho > data_aligned_subpixelshift.dat"
aligned_subpixelshift_data=get_data('data_aligned_subpixelshift.dat')
aligned_boot_albedo=reform(aligned_subpixelshift_data(0,*))
aligned_boot_delta_albedo=alog10(reform(aligned_subpixelshift_data(1,*)))
aligned_boot_RMSE=alog10(reform(aligned_subpixelshift_data(2,*)))
aligned_boot_nframes=alog10(reform(aligned_subpixelshift_data(3,*)))
;
;
!P.MULTI=[0,2,3]
x1=0.8
y1=-0.6
x2=0.8
y2=-0.7
goplot,1,nframes,RMSE,boot_nframes,boot_RMSE,'log!d10!n N-frames','log!d10!n RMSE','seq. vs. unaligned boot',fsc_color('green'),[-1.4,-0.4]

x1=0.8
y1=-0.85
x2=0.8
y2=-0.9
goplot,1,nframes,RMSE,aligned_boot_nframes,aligned_boot_RMSE,'log!d10!n N-frames','log!d10!n RMSE','seq. vs. Aligned boot',fsc_color('green'),[-1.4,-0.4]
;
x1=0.8
y1=-2.2
x2=0.8
y2=-2.3
goplot,1,nframes,delta_albedo,boot_nframes,boot_delta_albedo,'log!d10!n N-frames','log!d10!n !7D!3 Albedo','seq. vs. unaligned boot',fsc_color('green'),[-2.8,-2.0]
;
x1=-1.3
y1=-2.15
x2=-1.3
y2=-2.2
goplot,1,RMSE,delta_albedo,boot_RMSE,boot_delta_albedo,'log!d10!n RMSE','log!d10!n !7D!3 Albedo','seq. vs. unaligned boot',fsc_color('green'),[-2.8,-2.0]
;
nframes=reform(data(3,*))
delta_albedo=reform(data(1,*))
boot_nframes=reform(intshift_data(3,*))
boot_delta_albedo=reform(intshift_data(1,*))
aligned_boot_albedo=reform(aligned_subpixelshift_data(0,*))
aligned_boot_delta_albedo=(reform(aligned_subpixelshift_data(1,*)))
aligned_boot_RMSE=(reform(aligned_subpixelshift_data(2,*)))
aligned_boot_nframes=(reform(aligned_subpixelshift_data(3,*)))
;
x1=-1.1
y1=-2.75
x2=-1.1
y2=-2.68
goplot,3,nframes,albedo,boot_nframes*1.05,boot_albedo,'N-frames','Albedo','seq. vs. unaligned boot',fsc_color('green'),[0.29,0.34]
;..........................
x=nframes
y=albedo
;------------------------
xx=boot_nframes
yy=boot_albedo
; --- alternative--------
xx=aligned_boot_nframes
yy=aligned_boot_albedo
;------------------------
openw,48,'stats.dat'
idx=where(x eq 3)
jdx=where(xx eq 3)
printf,48,x(idx(0)),stddev(y(idx))/mean(y(idx))*100.,xx(jdx(0)),stddev(yy(jdx))/mean(yy(jdx))*100.
;..........................
idx=where(x eq 6)
jdx=where(xx eq 6)
printf,48,x (idx(0)),stddev(y(idx))/mean(y(idx))*100.,xx(jdx(0)),stddev(yy(jdx))/mean(yy(jdx))*100.
;..........................
idx=where(x eq 12)
jdx=where(xx eq 12)
printf,48,x(idx(0)),stddev(y(idx))/mean(y(idx))*100.,xx(jdx(0)),stddev(yy(jdx))/mean(yy(jdx))*100.
;..........................
idx=where(x eq 25)
jdx=where(xx eq 25)
printf,48,x(idx(0)),stddev(y(idx))/mean(y(idx))*100.,xx(jdx(0)),stddev(yy(jdx))/mean(yy(jdx))*100.
;..........................
idx=where(x eq 50)
jdx=where(xx eq 50)
printf,48,x (idx(0)),stddev(y(idx))/mean(y(idx))*100.,xx(jdx(0)),stddev(yy(jdx))/mean(yy(jdx))*100.
;..........................
idx=where(x eq 100)
jdx=where(xx eq 100)
printf,48,x(idx(0)),stddev(y(idx))/mean(y(idx))*100.,xx(jdx(0)),stddev(yy(jdx))/mean(yy(jdx))*100.
;..........................
close,48

data=get_data('stats.dat')
x1=-1.1
y1=-2.75
x2=-1.1
y2=-2.68
xx=reform(data(0,*))
yy=reform(data(1,*))
xxx=reform(data(2,*))
yyy=reform(data(3,*))
idx=where(finite(yyy) eq 1)
xxx=xxx(idx)
yyy=yyy(idx)
goplot,3,xx,yy,xxx,yyy,'N-frames','A S.D. in % of A','seq. vs. boot',fsc_color('green'),[0.0,1.1]
 end
