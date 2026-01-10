bbso=readfits('~/ASTRO/EARTHSHINE/BBSOimages/l07jul190039.fts')
bbso=rot(bbso,62)
ours=readfits('/media/bf458fbd-da4b-4083-b564-16d3aceb4c3e/MOONDROPBOX/JD2456028/2456027.9937044MOON_B_SKEP02.fits.gz')
ours=avg(ours,2)
ours=rot(ours,205)
ours=ours(*,320)
bbso=bbso(*,240)
!P.CHARSIZE=1.7
!P.thick=2.
!x.thick=2.
!y.thick=2.
plot_io,ours,xstyle=3,xtitle='Column ¤',ytitle='Counts'
oplot,shift((bbso-1311+392)/1.85,-11),color=fsc_color('red')
end
