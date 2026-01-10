file='lastline03'
openr,1,file
readf,1,target
i=0
while not eof(1) do begin
readf,1,a,b
if (i eq 0) then x=a else x=[x,a]
if (i eq 0) then y=b else y=[y,b]
i=i+1
endwhile
close,1
y=(y-target)/target*100.0
plot,x,y,charsize=2,xtitle='power',ytitle='BS/ES, pct !7D!3 from target',xstyle=1,ystyle=1,title='solid: w=0.03, dashed; w=0.01'
plots,[1.5,2.5],[0,0],thick=3
;..................
file='lastline01'
openr,1,file
readf,1,target
i=0
while not eof(1) do begin
readf,1,a,b
if (i eq 0) then x=a else x=[x,a]
if (i eq 0) then y=b else y=[y,b]
i=i+1
endwhile
close,1
y=(y-target)/target*100.0
oplot,x,y,linestyle=2
end