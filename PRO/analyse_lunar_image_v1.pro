PRO godostuff,im
l=size(im,/DIMENSIONS)
tvscl,im
x=defroi(l(0),l(1),/RESTORE,ZOOM=2)
stop
return
end

PRO feature,im_in,feature_name,pixel_ids1,pixel_stats1
;
im=im_in
l=size(im,/dimensions)
if (feature_name eq 'Grimaldi') then begin

; display image and scale for vissibility if needed

window,/FREE,xsize=l(0),ysize=l(1)
tvscl,im
read,answer,prompt='Is feature '+feature_name+' in the bright side? (1/0)'
if (answer eq 0) then begin
    im=alog10(im_in) ; or rescale the faint side...
    tvscl,im
endif
godostuff,im
stop
;-------------------------------
endif
if (feature_name eq 'Crisium') then begin


endif
return
end


FUNCTION removescattered,im_in
;
return,im_in
end

file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\Moon_simulated_53.FIT'
im=readfits(file)

;==============================
; remove scattered light in sky
im=removescattered(im)

;==============================
; measure one feature
feature,im,'Grimaldi',pixel_ids1,pixel_stats1
;==============================
; measure other feature
feature,im,'Crisium',pixel_ids2,pixel_stats2

;==============================
; forumlate results
cal_results,pixel_stats1,pixel_stats2,result_stats

;==============================
; print results
print_results,result_stats


end