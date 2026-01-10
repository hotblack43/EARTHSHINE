;
lambda=550.0	; nm
field=0.9 ; width of required field in degrees
inputhole=1.	; plotted hole diameter in mm
openw,12,'data.dat'
for hole=0.1,2,0.1 do begin	; hole diameter in mm
	focal_length=(hole/2.)^2/(lambda*1e-9*1e3)	; the 'optimal' or 'natural' focal length, in mm
	Airy_diameter=1.22*focal_length*lambda*1e-9*1e3/hole	; size of Airy disk at screen
	field_width=focal_length*sin(field*!dtor)	; width of field at screen, in mm
	resolution=field_width/Airy_diameter	; resolution of the image
	res_elem_on_Moon=focal_length*sin(32./60.*!dtor)/Airy_diameter ; number of resolving elements across lunar diameter
	printf,12,hole,focal_length,Airy_diameter,field_width,resolution,res_elem_on_Moon
endfor	; end of hole loop
close,12
; -------------------- PLOT THE DATA AS A NOMOGRAM -------------
file='data.dat'
data=get_data(file)
hole=reform(data(0,*))
focal_length=reform(data(1,*))
Airy_diameter=reform(data(2,*))
field_width=reform(data(3,*))
resolution=reform(data(4,*))
res_elem_on_Moon=reform(data(5,*))
;
plot_io,hole,focal_length,xtitle='Hole diameter [mm]',charsize=2,psym=-4,ytitle='',title=strmid(string(field),0,9)+' degree field.'
oplot,hole,field_width,psym=-5
oplot,hole,resolution,psym=-7
labels=['focal length [mm]','field width [mm]','resolution']
legend,labels,psym=[4,5,7],charsize=1.2
best_focal=interpol(focal_length,hole,inputhole)
print,format='(a,f8.3,a)','Best focal length at hole of'+string(inputhole)+' mm diam: ',best_focal
best_field_width=interpol(field_width,hole,inputhole)
print,format='(a,f8.3,a)','Field width at hole of'+string(inputhole)+' mm diam: ',best_field_width
best_resolution=interpol(resolution,hole,inputhole)
print,format='(a,f8.3,a)','Resolution at hole of'+string(inputhole)+' mm diam: ',best_resolution
best_res_elem_on_Moon=interpol(res_elem_on_Moon,hole,inputhole)
print,format='(a,f8.3,a)','Resolving elements across Moon at hole of'+string(inputhole)+' mm diam: ',best_res_elem_on_Moon
plots,[inputhole*0.8,inputhole*1.2],[best_field_width,best_field_width]
plots,[inputhole,inputhole],[1,2000]
plots,[0.0,inputhole],[best_resolution,best_resolution],linestyle=2
plots,[inputhole,2.0],[best_focal,best_focal],linestyle=3
print,format='(a,5(f8.3,a),1x,a)',' & ',field,' & ',inputhole,' & ',best_focal,' & ',best_field_width,' & ',best_res_elem_on_Moon,' \\'
end
