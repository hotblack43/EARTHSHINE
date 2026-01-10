PRO fix_stddev,x,ncount
meanval=mean(x,/double)
x=(x-meanval)/sqrt(ncount,/double)+meanval
return
end
