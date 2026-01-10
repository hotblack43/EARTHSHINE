x=randomu(seed,10000)
y=x+0.2*randomn(seed,10000)
plot,x,y,psym=3
scatter_col,x,y,minx=0,maxx=1,miny=-1,maxy=2,binx=0.04,biny=0.01, $
n_lev=5,no_line=no_line,/revert
end
