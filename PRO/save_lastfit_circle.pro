PRO save_lastfit_circle,file,x00,y00,radius
openw,72,'lastfit_circle'
printf,72,x00,y00,radius
close,72
return
end
