data=get_data('aha1.dat')
jd=reform(data(0,*))
ratio=reform(data(1,*))
err=reform(data(2,*))
plot,jd,ratio,psym=7
oploterr,jd,ratio,err*ratio/100.
end
