PRO match_level,x1,y1,x2,y2,x2new,y2new
; Will match the y levels of the second to the first
; OUTPUT is in x2new and y2new
xstart=min([x1,x2])
xend=max([x1,x2])
idx=where(x2 ge xstart and x2 le xend)
jdx=where(x1 ge xstart and x1 le xend)
; robust fit to red crosses
res1=robust_linefit(x2(idx),y2(idx))
Y_redline=res1(0)+res1(1)*x2(idx)
;oplot,x2(idx),Y_redline,psym=1,color=fsc_color('red')
; robust fit to white crosses
res2=robust_linefit(x1(jdx),y1(jdx))
Y_greenline=res2(0)+res2(1)*x2(idx)
;oplot,x2(jdx),Y_greenline,psym=1,color=fsc_color('green')
; difference between red and green lines
difference=Y_redline-Y_greenline
; now shift red points down by that difference
x2new=x2(idx)
y2new=y2-difference
return
end
