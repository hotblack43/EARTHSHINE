; tester for the linmicx BAeysian fitter
n=100
x=randomu(seed,n)
xsig=randomn(seed,n)*0.01
ysig=randomn(seed,n)*0.0
a=1.0
b=4.0
noise=randomn(seed,n)
y=a+b*x+noise
LINMIX_ERR, X, Y, POST, XSIG=xsig, YSIG=ysig, maxiter=500;, XYCOV=, DELTA=, NGAUSS=, /SILENT,
;                /METRO, MINITER= , MAXITER=
;-----------------
res=linfit(x,y,/double,sigma=sigs)
print,'LINFIT:'
print,res
print,'+/-',sigs
print,'LINMIX:'
print,mean(post.alpha),mean(post.beta)
print,'+/-',stddev(post.alpha),stddev(post.beta)
end
