; routine to test the drawing of gamma distributions, and the subsequent fitting
alpha=1.0
beta=4.0
print,'True alfa,beta:',alpha,beta
y=draw_gamma(alpha,beta,n=100000L)
; remove 'dry days'
wetday_limit=1.0
y=y(where(y gt wetday_limit))
wetday_limit=1.1
; perform the fit
;........... all data
param=fitgamma(y,thres=0.0,method=2)
print,'All data fit: '
print,param
;........... just the lower 90% of the data
param=fitgamma(y(where(y lt 0.9*max(y))),thres=wetday_limit,method=2)
print,'Below 90% of max fit: '
print,param
;........... just the lower 80% of the data
param=fitgamma(y(where(y lt 0.8*max(y))),thres=wetday_limit,method=2)
print,'Below 80% of max fit: '
print,param
;........... just the lower 70% of the data
param=fitgamma(y(where(y lt 0.7*max(y))),thres=wetday_limit,method=2)
print,'Below 70% of max fit: '
print,param
;........... just the data below mean 
param=fitgamma(y(where(y lt mean(y))),thres=wetday_limit,method=2)
print,'Below mean fit: '
print,param
;........... just the data above mean 
param=fitgamma(y(where(y gt mean(y))),thres=wetday_limit,method=2)
print,'Above mean fit: '
print,param
;........... just the data above 0.7*mean 
param=fitgamma(y(where(y gt 0.7*mean(y))),thres=wetday_limit,method=2)
print,'Above 0.7*mean fit: '
print,param
;........... just the data above 0.1*mean 
param=fitgamma(y(where(y gt 0.1*mean(y))),thres=wetday_limit,method=2)
print,'Above 0.1*mean fit: '
print,param
;........... just the data above 0.05*mean 
param=fitgamma(y(where(y gt 0.05*mean(y))),thres=wetday_limit,method=2)
print,'Above 0.05*mean fit: '
print,param
end
