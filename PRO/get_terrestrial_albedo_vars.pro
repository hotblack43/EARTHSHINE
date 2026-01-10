PRO get_day,h,info
print,h
stop
return
end



file1=file_search('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\OUTPUT\OUTPUT\Lunar*',count=n)

openw,23,'data.dat'
for i=0,n-1,1 do begin
print,file1(i)
albedo_var_im=double(readfits(file1(i)))
sky=mean(albedo_var_im(11:101,386:474))
xx=105
yy=224
width=11
albedovar_Grimaldi_pixel=mean(albedo_var_im(xx-width:xx+width,yy-width:yy+width))-sky
albedovar_Crisium_pixel=mean(albedo_var_im(402:415,303:315))-sky
print,albedovar_Grimaldi_pixel,albedovar_Crisium_pixel,albedovar_Grimaldi_pixel/albedovar_Crisium_pixel
printf,23,i,albedovar_Grimaldi_pixel/albedovar_Crisium_pixel

endfor
close,23
;------------
data=get_data('data.dat')
ratio_obs=reform(data(1,*))

days=indgen(n_elements(ratio_obs))/24.
!P.MULTI=[0,1,1]
!P.charsize=3

if (width eq 3) then plot,days,ratio_obs,title='Observed Grimaldi/Crisium ratio',charsize=2,psym=-7 ,xtitle='Days',xstyle=1
if (width gt 3) then oplot,days,ratio_obs
print,'sky=',sky

end

