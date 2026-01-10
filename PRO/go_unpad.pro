FUNCTION go_unpad,imout
l=size(imout,/dimensions)
n=l(0)/3.
out=imout(n:2*n-1,n:2*n-1)
return, out
end
