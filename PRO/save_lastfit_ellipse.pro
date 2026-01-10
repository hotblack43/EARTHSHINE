PRO save_lastfit_ellipse,file,x00,y00,radius1,radius2
openw,72,'lastfit_ellipse'
printf,72,x00,y00,radius1,radius2
close,72
return
end
