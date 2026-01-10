PRO analyze_sameness,ds1,ds2,ds3,ds4,ds5,fn
; will analyze how the 5 different CRAY runs compare
print,'Resuts for filter '+fn
print,'SD DS1:',stddev(ds1)
print,'SD DS2:',stddev(ds2)
print,'SD DS3:',stddev(ds3)
print,'SD DS4:',stddev(ds4)
print,'SD DS5:',stddev(ds5)
print,'SD of DS1-DS2 (32 b, 5x5 vs 11x11): ',stddev(DS1-DS2)/mean(ds1)*100.0,'%'
print,'SD of DS2-DS3 (11x11, 32b vs 64b): ',stddev(DS2-DS3)/mean(ds2)*100.0,'%'
print,'SD of DS3-DS4 (11x11, 1 or 2 iters): ',stddev(DS3-DS4)/mean(ds3)*100.0,'%'
return
end


function isnumeric,input
  on_ioerror, false
  test = double(input)
  return, 1
  false: return, 0
end
PRO parse,s,array
array=strsplit(s,' ',/extract)
return
end

PRO stripletters,s,justnumbers_str
parse,s,array
n=n_elements(array)
line=array(0)+' '
for i=1,n-2,1 do line=line+array(i)+' '
justnumbers_str=line
return
end

FUNCTION get_data_stripender,filname 
; very much like get_data.pro butstrips any strings off the end of the line read in
get_lun,u
get_lun,w
openr,w,filname
s=''
openw,u,'jhgiqshdgcfjkq.dat'
while not eof(w) do begin
readf,w,s
stripletters,s,justnumbers_str
printf,u,justnumbers_str
endwhile
close,u
close,w
data=get_data('jhgiqshdgcfjkq.dat')
free_lun,w
free_lun,u
return,data
end

PRO gethedata,data,filname,jd,ds1,ds2,ds3,ds4,ds5,bs,pcterr,ratio,ratio_orig
	;data=get_data(filname)
	data=get_data_stripender(filname)
jd=reform(data(0,*))
	; sort in ascending jd order
	idx=sort(jd)
	data=data(*,idx)
	jd=reform(data(0,*))
	ds1=reform(data(1,*))
	ds2=reform(data(2,*))
	ds3=reform(data(3,*))
	ds4=reform(data(4,*))
	ds5=reform(data(5,*))
	bs=reform(data(6,*))
	pcterr=reform(data(7,*))
	ratio=reform(data(8,*))
ratio_orig=reform(data(9,*))
	; get rid of obviously bad points
	idx=where(ratio gt 0)
	data=data(*,idx)
	jd=reform(data(0,*))
	ds1=reform(data(1,*))
	ds2=reform(data(2,*))
	ds3=reform(data(3,*))
	ds4=reform(data(4,*))
	ds5=reform(data(5,*))
	bs=reform(data(6,*))
	pcterr=reform(data(7,*))
	ratio=reform(data(8,*))
ratio_orig=reform(data(9,*))
	return
	end

	;
	filternames=['B','V','VE1','VE2','IRCUT']
	for ifil=0,n_elements(filternames)-1,1 do begin
	filname=strcompress('compared_EFM_results_'+filternames(ifil)+'.dat',/remove_all)
	gethedata,data,filname,jd,ds1,ds2,ds3,ds4,ds5,bs,pcterr,ratio,ratio_orig
        analyze_sameness,ds1,ds2,ds3,ds4,ds5,filternames(ifil)
;
!P.CHARSIZE=1.2
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.MULTI=[0,2,2]
plot,jd-jd(0),ratio,xtitle='JD fraction',ytitle='BS/DS for '+filternames(ifil),psym=7
oploterr,jd-jd(0),ratio*pcterr/100.0
oplot,jd-jd(0),ratio_orig,psym=1,color=fsc_color('red')
plot,ratio,ratio_orig,psym=7,/isotropic,xtitle='BS/DS corrected',ytitle='BS/DS un-corrected'
;plot,jd-jd(0),psym=7,pcterr,xtitle='JD fraction',ytitle='% err'
ymax=min([max(!X.crange),max(!Y.CRANGE)])
oplot,[0,ymax],[0,ymax],linestyle=2
histo,pcterr,-10,10,1
print,'   corrected SD/mean for ',filternames(ifil),' =',stddev(ratio)/mean(ratio)*100.0,' %.'
print,'un-corrected SD/mean for ',filternames(ifil),' =',stddev(ratio_orig)/mean(ratio_orig)*100.0,' %.'
endfor
end
