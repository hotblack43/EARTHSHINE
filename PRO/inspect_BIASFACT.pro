 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end

PRO getBIASFACT,h,biasfact
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'BIASFACT') ne -1)
 date_str=strmid(h(ipos),11,21)
 biasfact=float(date_str)
 biasfact=biasfact(0)
 return
 end

; will read the BIASFACT keyword and its value and make a plot
ifONLYplot=1
if (ifONLYplot ne 1) then begin
files=file_search('/data/pth/DARKCURRENTREDUCED/*.fits',count=n)
openw,1,'biasfact.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),h)
getBIASFACT,h,BIASFACT
get_time,h,dectime
printf,1,format='(i4,1x,f15.7,1x,f12.7)',i,dectime,BIASFACT
print,format='(i4,1x,f15.7,1x,f12.7)',i,dectime,BIASFACT
endfor
close,1
endif
;
data=get_data('biasfact.dat')
num=reform(data(0,*))
JD=reform(data(1,*))
factor=reform(data(2,*))
!P.MULTI=[0,1,2]
plot,xstyle=3,ystyle=3,num,factor,xtitle='Image seq. #',ytitle='Bias factor',charsize=2,psym=7
plot,xstyle=3,ystyle=3,jd,factor,xtitle='JD',ytitle='Bias factor',charsize=0.9,psym=7
idx=where(factor gt 1.08)
openw,33,'over1p08.txt'
for i=0,n_elements(idx)-1,1 do begin
printf,33,format='(f15.7)',JD(idx(i))
endfor
close,33
end
