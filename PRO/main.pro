;
; This is to test the program get_flat and gaincalib coded by Jongchul Chae
; For deatils, please refer to Chae, J. 2004, Solar Physics, 221, 1.
; This program specifically reproduces Fig 1 of this paper.
; In addition to the conventional IDL package for FITS, you should have the following
; IDL routines.
;      main.pro (this program)
;      get_flat.pro (driver)
;      gaincalib.pro (the key program)
;      alignoffset.pro  (to determine realtive displacements)
;      shift_sub.pro   (to displace images with sub-pixel accuracies)
;


f=findfile('m*.fts')
darkfile='dark.fts'
get_flat,f, 'flat.fts', darkfile,l, m, obj=obj, c=c,  maxiter=20
writefits, 'obj.fts', obj
writefits, 'c.fts', c
flat=readfits('flat.fts', /sil)
obj=readfits('obj.fts', /sil)
k=1
image=(readfits(f(k), /sil)-readfits(darkfile, /sil))
image1=image/flat

fig:
set_plot, 'ps'

ximg=8
yimg=8
xgap=0.05



device, bits=8, xs=2*ximg+xgap*1, ys=2*yimg+xgap,encap=0, xoff=3, yoff=5, $
    file='fg_hares.ps'
device, /bold
tv,   bytscl(congrid(alog10(flat),512,512), -0.05, 0.05), ximg+xgap,yimg+xgap, xs=ximg, ys=yimg, /cen
tv,   bytscl(congrid(alog10(obj)-alog10(median(obj)),512,512), -0.05, 0.05), ximg+xgap, 0, xs=ximg, ys=yimg, /cen
tv,   bytscl(congrid(alog10(image)-alog10(median(image)),512,512), -0.05, 0.05), 0,yimg+xgap, xs=ximg, ys=yimg, /cen
tv,   bytscl(congrid(alog10(image1)-alog10(median(image1)),512,512), -0.05, 0.05), 0, 0, xs=ximg, ys=yimg, /cen
xyouts, /norm, [0.03, 0.53, 0.03, 0.53], [0.53, 0.53, 0.03, 0.03], $
         '('+['a','b','c','d']+')', font=0, size=1.5, color=255
device, /close




set_plot, 'win'

final:
end

