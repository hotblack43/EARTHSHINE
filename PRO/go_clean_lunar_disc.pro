

PRO go_clean_lunar_disc,res,theta,theta_step,clean_image,radii,angle,removed_light
; find the cone of the image that can be corrected using the coefficients in 'res'
;------------------------------------------------------
idx=where(angle gt theta and angle le theta+theta_step)
for i=0,n_elements(idx)-1,1 do begin
	correction=radii(idx(i))*res(1)+res(0)
	clean_image(idx(i))=clean_image(idx(i))-correction
	removed_light(idx(i))=correction
;	print,'Applied correction:',correction,' at radius ',radii(idx(i))
endfor
return
end
