FUNCTION hmm,x
y=x
y=y(sort(y))
n=n_elements(y)
y=y(0.25*n:0.75*n)
value=mean(y,/double)
return,value
end
