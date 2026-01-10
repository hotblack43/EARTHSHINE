n=1000000L
x=randomn(seed,n)
h=histogram(x,min=0,max=1,binsize=0.001,reverse_indices=r)
for i=0,n_elements(h)-2,1 do print,i,n_elements(x[R[R[I] : R[i+1]-1]])
end
