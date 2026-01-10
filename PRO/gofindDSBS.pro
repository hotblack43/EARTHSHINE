PRO gofindDSBS,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS
; determine if BS is to the right or the left of the center
if (cg_x gt x0) then begin
; BS is to the right
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0-radius*2./3.-w:x0-radius*2./3.+w,y0-w:y0+w))
endif
if (cg_x lt x0) then begin
; BS is to the left
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0+radius*2./3.-w:x0+radius*2./3.+w,y0-w:y0+w))
endif
return
end
