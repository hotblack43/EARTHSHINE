;for inum=0,83,1 do begin
loadct,40
inum=18
!P.background=fsc_color('white')
set_plot,'ps'
if (inum le 9) then numstr='0'+string(inum)
if (inum gt 9) then numstr=string(inum)
stack=readfits(strcompress('PCTerrorImage_LunarImg_00'+numstr+'.fit',/remove_all))
im=reform(stack(*,*,0))
ideal=reform(stack(*,*,1))
contour,bytscl(ideal),xstyle=3,ystyle=3,$
/cell_fill,nlevels=101,/isotropic
contour,/overplot,rebin(abs(rebin(im,32,32)),512,512),levels=[-1,0,1,2,3,5,10,20,40],c_labels=findgen(20)*0+1,$
c_thick=[1,1,3,1,1,1,1,1,1,1,1,1,1]
contour,rebin(abs(rebin(im,32,32)),512,512),/overplot,levels=[-1,0,1],/downhill
;write_jpeg,'hej.jpeg',tvrd()
;endfor
end

