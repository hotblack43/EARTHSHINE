file='C:\Documents and Settings\Peter Thejll\Desktop\equidstant.wav'
res_equi=float(read_wav(file,rate))
file='C:\Documents and Settings\Peter Thejll\Desktop\onecloser.wav'
res_one=float(read_wav(file,rate))
file='C:\Documents and Settings\Peter Thejll\Desktop\otherclosest.wav'
res_other=float(read_wav(file,rate))
!P.multi=[0,1,3]
xstart=13500
width=300
plot,res_equi(0,*),charsize=2,xrange=[xstart,xstart+width]
oplot,res_equi(1,*),thick=3
xstart=10500
width=300
plot,res_one(0,*),charsize=2,xrange=[xstart,xstart+width]
oplot,res_one(1,*),thick=3
xstart=15000
width=300
plot,res_other(0,*),charsize=2,xrange=[xstart,xstart+width]
oplot,res_other(1,*),thick=3
end