PRO get_SSNo,fracyear,SSNo
file='C:\Documents and Settings\Peter Thejll\My Documents\WORK\DATA\MONTHLY.PLT'
data=get_data(file)
yy=reform(data(0,*))
mm=reform(data(1,*))
SSNo= reform(data(2,*))
fracyear=yy+(mm-1)/12.
return
end

get_SSNo,x,y
plot,x,y
end