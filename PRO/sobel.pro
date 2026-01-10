FUNCTIO sobel,im
x=[[-1.,0,1.],[-2.,0,2.],[-1.,0,1.]]
y=[[1.,2.,1.],[0,0,0],[-1.,-2.,-1.]]
resx=convol(im,x)
resy=convol(im,y)
return,abs(rex)+abs(resy)
end
