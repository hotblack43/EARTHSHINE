ncols=5
nrows=4
row=transpose(indgen(nrows))
for i=0,ncols-2,1 do row=[row,transpose(indgen(nrows))]
print,row

col=indgen(ncols)
for i=0,nrows-2,1 do col=[[col],[indgen(ncols)]]
print,col
end
