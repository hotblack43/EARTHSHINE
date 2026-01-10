file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\EMMAs\plotme.dat'
data=get_data(file)
x=reform(data(0,*))
y=reform(data(1,*))
plot,x,y
end