varnames=['alfa1','rlimit','pedestal','albedo','xshift','corefactor','contrast','yshift']
data=get_data('correlation_matrix.dat')         
idx=where(abs(data) gt 0.5 and abs(data) ne 1)
liste=array_indices(data,idx)
l=size(liste,/dimensions)
for k=0,l(1)-1,1 do print,varnames(liste(0,k)),' depends on ',varnames(liste(1,k)), ' : ',data(liste(0,k),liste(1,k))
end
