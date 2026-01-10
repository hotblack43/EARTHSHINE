pro get_means,data,x,y,yerr
line=reform(data(0,*))
line=line(sort(line))
line=line(uniq(line))
n=n_elements(line)
x=[]
y=[]
yerr=[]
for k=0,n-1,1 do begin
kdx=where(data(0,*) eq line(k))
x=[x,line(k)]
y=[y,mean(data(3,kdx))]
yerr=[yerr,robust_sigma(data(3,kdx))]
endfor
return
end

; Version 2
!X.style=3
!P.charsize=1.3
!P.charthick=3
!P.MULTI=[0,1,1]
data=get_data('patches.dat')
radfra=reform(data(0,*))
p1=reform(data(1,*))
p2=reform(data(2,*))
pct=reform(data(3,*))
illfrac=reform(data(4,*))
print,'Min,Max illfrac: ',min(illfrac),max(illfrac)
;histo,illfrac,0,1,0.1
idx=where(illfrac ge 0.50)	; fetch all data
print,n_elements(idx)
data=data(*,idx)
get_means,data,x,y,yerr
plot,ystyle=3,xrange=[0.5,1.1],yrange=[0,25],psym=7,x,y,xtitle='Radius fraction',ytitle='mean difference [%]'
oplot,[!X.crange],[1,1],linestyle=2
oploterr,x,y,yerr
;
data=get_data('patches.dat')
radfra=reform(data(0,*))
p1=reform(data(1,*))
p2=reform(data(2,*))
pct=reform(data(3,*))
illfrac=reform(data(4,*))
idx=where(illfrac ge 0.45 and illfrac le 0.50)	; fetch all data
print,n_elements(idx)
data=data(*,idx)
get_means,data,x,y,yerr
pcolor=!P.color
!P.color=fsc_color('red')
oploterr,x+0.01,y,yerr
!P.color=pcolor
;
data=get_data('patches.dat')
radfra=reform(data(0,*))
p1=reform(data(1,*))
p2=reform(data(2,*))
pct=reform(data(3,*))
illfrac=reform(data(4,*))
idx=where(illfrac ge 0.36 and illfrac le 0.45)	; fetch all data
print,n_elements(idx)
data=data(*,idx)
get_means,data,x,y,yerr
pcolor=!P.color
!P.color=fsc_color('green')
oploterr,x+0.02,y,yerr
!P.color=pcolor
;
data=get_data('patches.dat')
radfra=reform(data(0,*))
p1=reform(data(1,*))
p2=reform(data(2,*))
pct=reform(data(3,*))
illfrac=reform(data(4,*))
idx=where(illfrac le 0.36)	; fetch all data
print,n_elements(idx)
data=data(*,idx)
get_means,data,x,y,yerr
pcolor=!P.color
!P.color=fsc_color('orange')
oploterr,x+0.03,y,yerr
!P.color=pcolor
end

