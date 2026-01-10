PRO save_fitted_pars_ellipse,file,x00,y00,radius1,radius2
fmt='(4(1x,f12.4),1x,a)'
openw,39,'moonfits.results',/append
printf,39,format=fmt,x00,y00,radius1,radius2,file
close,39
return
end
