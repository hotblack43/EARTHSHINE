PRO test_signif,y,yhat,R,fractionbetter
nMC=15000
for iMC=0,nMC-1,1 do begin
result=pseudo_t_guarantee_ac1(y,0.36,2,seed)
if (iMC eq 0) then Rarray=correlate(result,yhat) else Rarray=[Rarray,correlate(result,yhat)]
endfor
nbetter=n_elements(where(abs(Rarray) gt abs(R)))
fractionbetter=float(nbetter)/float(nMC)
return
end

file='workCastor.txt'
str=''
openr,1,file
readf,1,str
i=0
while not eof(1) do begin
readf,1,a,b,c,d,e,f
if (i eq 0) then sc=a else sc=[sc,a]
if (i eq 0) then duration=b else duration=[duration,b]
if (i eq 0) then sunspots=c else sunspots=[sunspots,c]
if (i eq 0) then idx=d else idx=[idx,d]
if (i eq 0) then co2=e else co2=[co2,e]
if (i eq 0) then ws=f else ws=[ws,f]
i=i+1
endwhile
close,1
openw,3,'Castor.dat'
;..................
for i=1,max(idx),1 do begin
print,'.....................................................................'
kdx=where(idx eq i)
x1=sunspots(kdx)
x2=co2(kdx)
y=ws(kdx)
n=n_elements(kdx)
;print,'n:',n
res=linfit(indgen(n),y,yfit=yhat) & y=y-yhat
res=linfit(indgen(n),x1,yfit=yhat) & x1=x1-yhat
res=linfit(indgen(n),x2,yfit=yhat) & x2=x2-yhat
!P.MULTI=[0,2,3]
plot,x1,ytitle='Sunspot #',charsize=1.4,psym=-7
plot,x2,ytitle='CO2',charsize=1.4,psym=-7
;................
res=linfit(x1,y,yfit=yhat)
r=correlate(x1,y)
plot,y,ytitle='Wind stress and scaled Sunspot #',charsize=1.4,psym=-7,title='R='+string(R)
oplot,yhat,thick=2
test_signif,y,x1,r,fractionbetter
print,'R(WS vs Sunspots):',r,' signif:',fractionbetter*100.0,' % are better by chance'
printf,3,'S',r,fractionbetter*100.0
;................
res=linfit(x2,y,yfit=yhat)
r=correlate(x2,y)
plot,y,ytitle='Wind stress and scaled CO2',charsize=1.4,psym=-7,title='R='+string(R)
oplot,yhat,thick=2
test_signif,y,x2,r,fractionbetter
print,'R(WS vs CO2):',r,' signif:',fractionbetter*100.0,' % are better by chance'
printf,3,'C',r,fractionbetter*100.0
;................
res=regress([transpose(x1),transpose(x2)],y,yfit=yhat)
r=correlate(yhat,y)
plot,y,ytitle='Wind stress',charsize=1.4,psym=-7,title='R='+string(R)
oplot,yhat,thick=2
test_signif,y,yhat,r,fractionbetter
print,'R(WS vs Sunpots+CO2):',r,' signif:',fractionbetter*100.0,' % are better by chance'
printf,3,'CS',r,fractionbetter*100.0
;................
;o=get_kbrd()
endfor
close,3
end
