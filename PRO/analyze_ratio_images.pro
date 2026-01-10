im=readfits('ratio.fits')
u=276+55
l=276-55
box=im(0:511,l:u)
l=size(box,/dimensions)
!P.MULTI=[0,2,1]
plot,total(box,2)/float(l(1)),xtitle='Column number',ytitle='Sum along columns',title='CoADD/LundMode image. OD=2987'
plots,[!x.crange],[1,1],linestyle=2
contour,im,/cell_fill,nlevels=11,xstyle=1,ystyle=1,/isotropic
contour,im,levels=[0.9,1.0,1.1],/overplot
end
