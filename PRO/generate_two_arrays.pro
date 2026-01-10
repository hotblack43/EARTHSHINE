PRO generate_two_arrays,ncols,nrows,row,col
row=transpose(indgen(nrows))
for i=0,ncols-2,1 do row=[row,transpose(indgen(nrows))]
col=indgen(ncols)
for i=0,nrows-2,1 do col=[[col],[indgen(ncols)]]
return
end
