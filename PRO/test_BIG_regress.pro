n=get_data('n.dat');25
data=1.0d0*get_data('scaled_array.dat')
l=size(data,/dimensions)
ncol=l(0)
nrows=l(1)

data=data(1:ncol-1,*) 	; skip first column
l=size(data,/dimensions)
ncol=l(0)
nrows=l(1)

train=0.8	; fraction to train on, rest is for test
; scrabmle the ordering
idx=randomu(seed,nrows)
data=data(*,sort(idx))
data1=data(*,0:train*nrows)
data2=data(*,train*nrows+1:nrows-1)
l=size(data,/dimensions)
ncol=l(0)
nrows=l(1)

xx=data1(0:ncol-2,*)
yy=reform(data1(ncol-1,*))/1000.0d0
xx_test=data2(0:ncol-2,*)
yy_test=reform(data2(ncol-1,*))/1000.0d0

siglev=0.001
res=backw_elim(xx,yy,/double,siglev,sigma=sigs,const=const,yfit=yhat,varlist=vars)
print,'Sig vars: ',vars
residuals=(yy-yhat)
res=regress(xx,yy,/double,sigma=sigs,yfit=yhat)
z=round(res/sigs)
im=reform(z,n,n)
nuls=setdifference(indgen(n*n),vars) 
im(nuls)=0
writefits,'z.fits',im
; test on the indicated regressors
res=regress(xx(vars,*),yy(*),/double,sigma=sigs,const=const,yfit=yhat)
ymodeltest=const+res#xx_test(vars,*)	; NOTE - the offset 'const' is for the full model, thus ignored here.
fejl=yy_test(*)-ymodeltest
print,'SD of errors: ',stddev(fejl)
end
