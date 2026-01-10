!P.MULTI=[0,1,2]
for i=0,29,1 do begin
if (i le 9) then numstr='000'+string(i)
if (i gt 9) then numstr='00'+string(i)
bbso=readfits(strcompress('OUTPUT/IDEAL/BBSO_cleaned__'+numstr+'.fit',/remove_all))
blind=readfits(strcompress('OUTPUT/IDEAL/Cleaned__'+numstr+'.fit',/remove_all))
ideal=readfits(strcompress('OUTPUT/IDEAL/InSpace__'+numstr+'.fit',/remove_all))
bbso_err=100.0*(bbso-ideal)/ideal
blind_err=100.0*(blind-ideal)/ideal
bbso_err=smooth(bbso_err,29,/edge_truncate,/NaN)
blind_err=smooth(blind_err,29,/edge_truncate,/NaN)
!P.CHARSIZE=2
;contour,[ideal/max(ideal)*100.0,bbso_err,blind_err],/cell_fill,nlevels=101,title=string(i)
;contour,[ideal/max(ideal)*100.0,bbso_err,blind_err],/overplot,levels=[-1000,-100,-50,0,50,100,1000],c_labels=indgen(7)*0+1
contour,[ideal/max(ideal)*100.0,bbso_err,blind_err],levels=[-1000,-100,-10,-1,-0.1,0,0.1,1,10,100,1000],c_labels=indgen(11)*0+1
endfor
end
