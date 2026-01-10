FUNCTION get_lro_albedo
; get the LRO albedo map. The 7 layers are the wavelength bands 
; 321, 360, 415, 566, 604, 643, 689 nm
im=READ_TIFF('Eshine/1x1_70NS_7b_wbhs_albflt_grid_geirist_tcorrect_w.tif', R, G, B,geotiff=hejsa)
im=rebin(im,7,1080,140*3)
blanks=fltarr(7,1080,(540-420)/2)*!VALUES.F_NAN
im=[[[blanks]],[[im]],[[blanks]]]
return,im
end

PRO getlro,lambdas,lro,lon_lro,lat_lro
lambdas=[321, 360, 415, 566, 604, 643, 689]
lro=get_lro_albedo()
lon_lro=findgen(1080)/3.
lat_lro=findgen(540)/3.-90
lat_lro=reverse(lat_lro)
clem=get_data('./Eshine/data_eshine/HIRES_750_3ppd.alb')
lon_clem=findgen(1080)/3.
lat_clem=findgen(540)/3.-90
return
end

PRO getclem,clem,lon_clem,lat_clem
clem=get_data('./Eshine/data_eshine/HIRES_750_3ppd.alb')
lon_clem=findgen(1080)/3.
lat_clem=findgen(540)/3.-90
return
end

;
getlro,lambdas,lro,lon_lro,lat_lro
; now the colour
x=lambdas(*)
openw,33,'lro_colour_slope.dat'
slope_map=fltarr(1080,540)
for k=0,1080-1,1 do begin
for l=0,540-1,1 do begin
y=reform(lro(*,k,l))
res=ladfit(x,y)
slope_map(k,l)=res(1)
if (finite(res(0)*res(1)) eq 1) then printf,33,k,l,res
if (finite(res(0)*res(1)) eq 1) then print,k,l,res
endfor
endfor
close,33
data=get_data('lro_colour_slope.dat')
histo,data(3,*),min(data(3,*)),max(data(3,*)),(max(data(3,*))-min(data(3,*)))/100.
print,'Mean slope: ',mean(data(3,*)),' /nm'
print,'SD:         ',stddev(data(3,*))
tvscl,slope_map
end

