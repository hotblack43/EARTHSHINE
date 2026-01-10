str="grep -v '\*' residual_stats.dat | awk 'NF >= 5 {print $1,$2,$3,$4,$5}' > erasme.now"
spawn,str
data=get_data('erasme.now')
jd=reform(data(0,*))
SDtotframe=reform(data(1,*))
SDcorner=reform(data(2,*))
mxlin=reform(data(3,*))
totfpct=reform(data(4,*))
 idx=where(sdcorner lt 2.3 and mxlin lt 440)
 idx=where(mxlin lt 440)
 idx=where(totfpct gt 0 and totfpct lt 0.2)
;data=data(*,idx)
 jd=reform(data(0,*))
 SDtotframe=reform(data(1,*))
 SDcorner=reform(data(2,*))
 mxlin=reform(data(3,*))
 totfpct=reform(data(4,*))
;
airm=[]
for k=0,n_elements(jd)-1,1 do begin
get_mlo_airmass,jd(k),am
airm=[airm,am]
endfor
;--------------------
!P.MULTI=[0,2,2]
histo,SDtotframe,2,4,0.05,xtitle='SD total frame'
histo,SDcorner,1.5,3.5,0.05,xtitle='SD in corner'
histo,mxlin,390,500,2.,xtitle='Max linevalue'
histo,totfpct,0,5,0.1,xtitle='SD of total flux'
end
