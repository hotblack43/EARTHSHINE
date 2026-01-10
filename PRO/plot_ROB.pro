file='c:\RSI\WORK\ROBERTSON_VOLCANIC.dat'
data=get_data(file)
x=reform(data(0,*))
y=reform(data(1,*))
plot,x,y
end