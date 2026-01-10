x=findgen(100.)+0.23
A=[102.13,1.,12.,13.]
COMP_VOIGT,X,A,F
plot_io,x,f,xrange=[min(x),max(x)],xstyle=1
end