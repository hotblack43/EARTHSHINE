!P.MULTI=[0,3,2]
fnames=['B','V','VE1','IRCUT','VE2']
data=get_data('albedo_and_errors_fromlonlatpatchANDbsonly.dat')
filter=reform(data(0,*))
JD=reform(data(1,*))
k_lonlat=reform(data(2,*))
k_error_lonlat=reform(data(3,*))
k_BS=reform(data(4,*))
k_error_BS=reform(data(5,*))
for ifilter=0,4,1 do begin
idx=where(filter eq ifilter)
xra=[min([k_lonlat(idx),k_BS(idx)]),max([k_lonlat(idx),k_BS(idx)])]
;xra=[0.0,0.4]
yra=xra
plot,charsize=2,xrange=xra,yrange=yra,title=fnames(ifilter),k_lonlat(idx),k_BS(idx),psym=3,xtitle='k from patch',ytitle='k from image'
oplot,[!X.crange(0),!X.crange(1)],[!Y.crange(0),!Y.crange(1)]
for k=0,n_elements(idx)-1,1 do begin
oplot,[k_lonlat(idx(k))-k_error_lonlat(idx(k)),k_lonlat(idx(k))+k_error_lonlat(idx(k))],[k_BS(idx(k)),k_BS(idx(k))]
oplot,[k_lonlat(idx(k)),k_lonlat(idx(k))],[k_BS(idx(k))-k_error_BS(idx(k)),k_BS(idx(k))+k_error_BS(idx(k))]
xyouts,k_lonlat(idx(k)),k_BS(idx(k)),string(long(JD(idx(k)))),orientation=-38
endfor
endfor
end
