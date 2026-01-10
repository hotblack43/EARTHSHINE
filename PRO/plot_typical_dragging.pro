im=readfits('typical_dragged_image.fits',h)
print,h
!P.MULTI= [0,1,2]
plot_io,yrange=[0.01,400],im(*,126),title='Cut across drag'
print,'Max of drag is: ',max(im(*,126))
oplot,im(*,100),color=fsc_color('red')
oplot,im(*,75),color=fsc_color('green')
oplot,im(*,50),color=fsc_color('blue')
oplot,im(*,25),color=fsc_color('orange')
plot_io,yrange=[0.01,400],im(450,*),title='Cut along drag'
end
