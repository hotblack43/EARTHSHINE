n=10000
x=randomu(seed,n,n)
CPU, TPOOL_MIN_ELTS=10000000000, TPOOL_NTHREADS=2  
print,!CPU
t1=systime(/seconds)
;z=ffT(x,-1)
z=max(x)
t2=systime(/seconds)
print,'delta when TPOOL_MIN_ELTS=10000000000:',t2-t1
CPU, TPOOL_MIN_ELTS=1000, TPOOL_NTHREADS=2  
print,!CPU
t3=systime(/seconds)
;z=ffT(x,-1)
z=max(x)
t4=systime(/seconds)
print,'delta when TPOOL_MIN_ELTS=1000:',t4-t3
print,(t2-t1)/(t4-t3)
end
