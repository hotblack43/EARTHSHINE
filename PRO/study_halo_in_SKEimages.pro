
;Analyses the halo profiles on the dark and bright sides of the SKE
; the point being that one sees diffracted (and internally reflected light only) whereas the other sees that as well as scattered light in the atmsophere
!P.MULTI=[0,1,2]
!P.charsize=2
!P.charthick=3
file='/media/thejll/842cc5fa-1b81-4eba-b09e-6e6474647d56/MOONDROPBOX/JD2455641/2455641.6410160Moon-CoAdd-SKE-MoonRightside-Exp1s.fits.gz'
im=readfits(file)
im=avg(im,2)
corner=mean(im(0:10,0:10))
im=im-corner
;--------------
SKEedgecol=255
middlerow=242
w=10
; plot to left of SKE edge
ic=0
for irow=middlerow-w,middlerow+w,1 do begin
line=im(*,irow)
line=line(0:SKEedgecol-2)
line=line/max(line)
line=reverse(line)
if (ic eq 0) then plot_oo,line,yrange=[1e-4,1],ystyle=3,xstyle=3,xtitle='Distance to left of edge',title='On SKE side'
if (ic ne 0) then oplot,line
ic=ic+1
endfor
; --- now to right of edge
ic=0
for irow=middlerow-w,middlerow+w,1 do begin
line=im(*,irow)
line=line(SKEedgecol+2:*)
line=line/max(line)
if (ic eq 0) then plot_oo,line,yrange=[1e-3,10],ystyle=3,xstyle=3,xtitle='Distance to right of edge',title='On sky side'
if (ic ne 0) then oplot,line
ic=ic+1
endfor
end
