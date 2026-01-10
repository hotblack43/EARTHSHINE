PRO get_dat,x,y,n,file
data=get_data(file)
x=reform(data(0,*))
y=reform(data(1,*))
n=n_elements(x)
return
end
