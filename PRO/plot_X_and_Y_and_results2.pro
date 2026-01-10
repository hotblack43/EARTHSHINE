; define plotting environment

type = 'X'

if ( type eq 'x') then begin
  set_plot,'x'
  device, pseudo_color = 8, decomposed = 0
  iwin = 0
  xsize = 600
  ysize = 850
endif

if ( type eq 'ps' ) then begin
  set_plot,'ps'
  device, filename='results.eps',/encapsulated,                       $
          xsize = 16., xoffset = 2., ysize = 25., yoffset = 2., $
          /color, bits_per_pixel = 8
endif

!y.omargin = [ 10, 10]
!p.charsize = 1.5
!P.thick=1.5
!X.thick=2
!Y.thick=2

;----------------------------
openr,78,'regionindicator.txt'
str=''
readf,78,str
close,78
!P.MULTI=[0,2,4]
file='X.dat'
data=get_data(file)
l=size(data,/dimensions)
n=l(1)
nmods=l(0)
mn=fltarr(nmods)
sd=fltarr(nmods)
for i=0,nmods-1,1 do begin
mn(i)=mean(data(i,*))
sd(i)=stddev(data(i,*))
endfor
plot,indgen(nmods)+1,mn,xtitle='Region',ytitle='X',xstyle=1,xrange=[0,nmods+1]
oploterr,indgen(nmods)+1,mn,sd
print,str
xyouts,/normal,0.5,0.95,str
;-----------------------
file='Y.dat'
data=get_data(file)
l=size(data,/dimensions)
n=l(1)
nmods=l(0)
mn=fltarr(nmods)
sd=fltarr(nmods)
for i=0,nmods-1,1 do begin
mn(i)=mean(data(i,*))
sd(i)=stddev(data(i,*))
endfor
plot,indgen(nmods)+1,mn,xtitle='GCM+RCM',ytitle='Y',xstyle=1,xrange=[0,nmods+1]
oploterr,indgen(nmods)+1,mn,sd
;

; plots
data=get_data('results_2.dat')
histo,data(0,*),0,max(data(0,*)),max(data(0,*))/15.,xtitle='% validation data error - LS'
histo,data(5,*),0,max(data(0,*)),max(data(0,*))/15.,xtitle='% validation data error - RND'
histo,data(2,*),0,10,1,xtitle='status'
plot,data(3,*),data(4,*),psym=7,xtitle='|x|',ytitle='|y|',xstyle=1,ystyle=1
print,'Mean validation error,STD LS :',mean(data(0,*)),stddev(data(0,*))
print,'Mean validation error,STD RND:',mean(data(5,*)),stddev(data(5,*))
plot_oo,data(0,*)/data(5,*),data(6,*),psym=7,xtitle='ratio LS/RND',ytitle='Condition number'
if ( type eq 'ps' ) then device,/close
end
