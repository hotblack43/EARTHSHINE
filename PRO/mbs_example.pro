file='hejsa.txt'
data=get_data(file)
x=reform(data(0,*))
y=reform(data(1,*))
plot,x,y
end
