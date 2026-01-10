!P.MULTI=[0,1,2]
n=10000L
m=100
; Generate the tow 'experimenatl series' 
x=randomn(seed,m)
y=x+2.3+5*randomn(seed,m)
x=(x-mean(x))/stddev(x)
y=(y-mean(y))/stddev(y)
difference=x-y
Target_RSSE=sqrt(total(difference^2))
plot,x
oplot,y,color=fsc_color('red')
print,'The Target RSSE is:',Target_RSSE
for i=0,n-1,1 do begin
z=randomn(seed,m)
w=randomn(seed,m)
z=(z-mean(z))/stddev(z)
w=(w-mean(w))/stddev(w)
difference=z-w
RSSE=sqrt(total(difference^2))
if (i eq 0) then liste=RSSE
if (i gt 0) then liste=[liste,RSSE]
endfor
idx=where(liste le Target_RSSE)
histo,liste,0,20,.1,xtitle='RSSE'
oplot,[Target_RSSE,Target_RSSE],[!Y.crange],linestyle=2
print,n_elements(idx)/float(n)*100.0,' % of the trials have smaller RSSE than the Target'
end
