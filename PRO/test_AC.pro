FUNCTION get_decortime,x
ac1=a_correlate(x,1,/double)
ac1=correlate(x,shift(x,-1))
print,'AC1=',ac1
tau=(1.+ac1)/(1.-ac1)
return,tau
end


!P.MULTI=[0,1,3]
file='AC_test.dat'
data=get_data(file)
before=reform(data(0,*))
n=n_elements(before)
after=reform(data(1,*))
tau_before=get_decortime(before)
tau_after=get_decortime(after)
print,'tau before prewhitening:',tau_before
print,'tau after prewhitening:',tau_after
randomseries=randomn(seed,n)
tau_random=get_decortime(randomseries)
print,'tau random noise:',tau_random
plot,before,title='Before prewhitening'
xyouts,/data,n*0.1,!Y.CRANGE(0)+0.1*(!Y.CRANGE(1)-!Y.CRANGE(0)),'!7s!3!ddecor!n='+string(tau_before),charsize=2
plot,after,title='After prewhitening'
xyouts,/data,n*0.1,!Y.CRANGE(0)+0.1*(!Y.CRANGE(1)-!Y.CRANGE(0)),'!7s!3!ddecor!n='+string(tau_after),charsize=2
plot,randomseries,title='N(0,1) noise'
xyouts,/data,n*0.1,!Y.CRANGE(0)+0.1*(!Y.CRANGE(1)-!Y.CRANGE(0)),'!7s!3!ddecor!n='+string(tau_random),charsize=2
end

