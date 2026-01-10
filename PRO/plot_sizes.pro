file='sizes'
data=get_data(file)
n=n_elements(data)
x=indgen(n)
plot_oo,x,data,xrange=[1,1e4],charsize=2,yrange=[1,1e8],psym=-7,xtitle='Rank',ytitle='File size'

end
