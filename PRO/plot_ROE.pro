file='ROE20070127.sec'
file='ROE20070129.sec'
openr,1,file
n=86400
T=fltarr(n)
H=T
D=T
Z=T
u=T
for i=0L,n-1,1 do begin
str=''
readf,1,str
parts=strsplit(str,' ',/EXTRACT)
T(i)=float(parts(1))
H(i)=float(parts(2))
D(i)=float(parts(3))
Z(i)=float(parts(4))
u(i)=float(parts(5))
endfor
close,1
!P.MULTI=[0,1,5]
plot,findgen(n)/3600.,T,title=file,xtitle='Hour',ytitle='T',ystyle=1,charsize=1.6
plot,findgen(n)/3600.,H,title=file,xtitle='Hour',ytitle='H',ystyle=1,charsize=1.6
plot,findgen(n)/3600.,D,title=file,xtitle='Hour',ytitle='D',ystyle=1,charsize=1.6
plot,findgen(n)/3600.,Z,title=file,xtitle='Hour',ytitle='Z',ystyle=1,charsize=1.6
plot,findgen(n)/3600.,u,title=file,xtitle='Hour',ytitle='u',ystyle=1,charsize=1.6
end
