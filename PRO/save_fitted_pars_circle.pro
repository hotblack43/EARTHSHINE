PRO save_fitted_pars_circle,file,x00,y00,radius
fmt='(3(1x,f12.4),1x,a)'
openw,39,'moonfits.results',/append
printf,39,format=fmt,x00,y00,radius,file
close,39
return
end
