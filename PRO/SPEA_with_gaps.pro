PRO condition,jd,ext,err,lim1,lim2,volcanic
; remove smooth
ext=ext-smooth(ext,13,/edge_truncate)
if (volcanic eq 0) then idx=where(jd le lim1 or jd ge lim2)
if (volcanic eq 1) then idx=where(jd ge lim1 and jd le lim2)
if (volcanic eq 2) then idx=where(jd gt -2)
jd=jd(idx)
ext=ext(idx)
err=err(idx)

return
end

FUNCTION convert_yy_doy_2_jd,year,doy
jd=julday(1,1,year)+doy-1
return,jd
end

; ---------------- MAIN PROG ---------------
files=['La_Palma_extinction_on_good_nights.dat','lasilla_1977_1996_yymmddhhmi.dat']
nfiles=n_elements(files)
keyfile=['SBC_list_MJJAS.dat','SBC_list_NDJFM.dat','FD_list_0p7_MJJAS.dat','FD_list_0p7_NDJFM.dat','SW_MJJAS_NDJFM.dat','SBC_list_NDJFM_MJJASd.dat','FD_list_all_WI_SU_months.dat','SPE_keydates_yy_doy.dat']
nkeys=n_elements(keyfile)
;...................
!P.MULTI=[0,2,3,0,0]


for ikey=0,nkeys-1,1 do begin
for ifil=0,nfiles-1,1 do begin
keydates=keyfile(ikey)
data=get_data(keydates) & year=reform(data(0,*)) & doy=reform(data(1,*))
jdkey=convert_yy_doy_2_jd(year,doy) & nkey=n_elements(jdkey)

for volcanic=0,2,1 do begin	; 0, 1 or 2 - 2 is do nothing
file=files(ifil)
data=get_data(file) & year=reform(data(0,*)) & mm=reform(data(1,*)) & dd=reform(data(2,*)) & hr=reform(data(3,*)) & mi=reform(data(4,*)) & ext=reform(data(5,*)) & err=reform(data(6,*))
jd=julday(mm,dd,year,hr,mi)
; condition the extinction data
if (volcanic eq 1) then volc_str='Volcanic '
if (volcanic eq 0) then volc_str='Non-Volcanic '
if (volcanic eq 2) then volc_str='All years '
 condition,jd,ext,err,julday(1,6,1991),julday(1,6,1994),volcanic
; loop over key dates, snipping out pieces of data, storing
half_win=21 ; odd number describing width of window to one side of key date
counts=findgen(2*half_win+1)
bins=findgen(2*half_win+1)
openw,12,'cutouts.dat'
for i=0,nkey-1,1 do begin
	idx=where(jd ge jdkey(i)-half_win and jd le jdkey(i)+half_win)
	if (n_elements(idx) gt half_win) then begin
		x_cutout=jd(idx)-jdkey(i)
	   	y_cutout=ext(idx)
	   	; remove trend
	   	;res=linfit(x_cutout,y_cutout,/double,yfit=yhat)
	   	;y_cutout=y_cutout-yhat
	   	; or remove mean (not both!)
	   	;y_cutout=y_cutout-mean(y_cutout)
	   	if (finite(mean(y_cutout)) ne 1) then stop
		for k=0,n_elements(x_cutout)-1,1 do printf,12,x_cutout(k),y_cutout(k)
	endif	; end of if idx
endfor ; loop over key dates
close,12
; now bin them
data=get_data('cutouts.dat')
x=reform(data(0,*))
y=reform(data(1,*))
idx=where(finite(y) eq 1)
x=x(idx)
y=y(idx)
idx=sort(x)
x=x(idx)
y=y(idx)
if (product(finite(y)) eq 0) then stop
h=histogram(x,min=-half_win,max=half_win,binsize=1,reverse_indices=r)
for ibin=0,n_elements(h)-2,1 do begin
	if (R(ibin) ne R(ibin+1)) then begin
		if(n_elements(R(R[ibin] : R[ibin+1]-1)) gt 2) then begin
		if (ibin eq 0) then begin
			xx=ibin-half_win
			yy=mean(y(R(R[ibin] : R[ibin+1]-1)))
			zz=n_elements(R(R[ibin] : R[ibin+1]-1))
			ww=stddev(y(R(R[ibin] : R[ibin+1]-1)))/sqrt(n_elements(R(R[ibin] : R[ibin+1]-1))-1)
		endif
		if (ibin gt 0) then begin
			xx=[xx,ibin-half_win]
			yy=[yy,mean(y(R(R[ibin] : R[ibin+1]-1)))]
			zz=[zz,n_elements(R(R[ibin] : R[ibin+1]-1))]
			ww=[ww,stddev(y(R(R[ibin] : R[ibin+1]-1)))/sqrt(n_elements(R(R[ibin] : R[ibin+1]-1))-1)	]
		endif
	endif
	endif
endfor
plot,xx,yy,psym=10,xtitle='Days offset from key day',ytitle='extinction',charsize=1.7,xstyle=1,title=file,subtitle=volc_str+keydates
oploterr,xx,yy,ww
mean1=mean(yy(where(xx lt 0))) & std1=stddev(yy(where(xx lt 0)))/sqrt(n_elements(where(xx lt 0))-1)
plots,[-half_win,0],[mean1,mean1],linestyle=0
plots,[-half_win,0],[mean1-std1,mean1-std1],linestyle=1
plots,[-half_win,0],[mean1+std1,mean1+std1],linestyle=1
mean1=mean(yy(where(xx ge 0))) & std1=stddev(yy(where(xx ge 0)))/sqrt(n_elements(where(xx ge 0))-1)
plots,[0,half_win],[mean1,mean1],linestyle=0
plots,[0,half_win],[mean1-std1,mean1-std1],linestyle=1
plots,[0,half_win],[mean1+std1,mean1+std1],linestyle=1
plot,xx,zz,psym=10,xtitle='Days offset from key day',ytitle='N',charsize=1.7,xstyle=1
endfor	; end of volcanic loop
endfor ; end of ikey loop
endfor ; end of ifil loop
end