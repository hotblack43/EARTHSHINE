path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455643/'
files=['align_stacked_2455643.4725818Arcturus-IRCUT-FILTER.fits','align_stacked_2455643.4800437Arcturus-B-FILTER.fits','align_stacked_2455643.4866171Arcturus-VE2-FILTER.fits','align_stacked_2455643.4891739Arcturus-V-FILTER.fits','align_stacked_2455643.5007650Arcturus-VE1-FILTER.fits','align_stacked_2455643.4911491Arcturus-IRCUT-FILTER.fits']
n=n_elements(files)
w=80
!P.CHARSIZE=2
for i=0,n-1,1 do begin
im=readfits(path+files(i))
help,im
idx=where(im eq max(im))
pos=array_indices(im,idx)
subim=im(pos(0)-w/2.:pos(0)+w/2.,pos(1)-w/2.:pos(1)+w/2.)
surface,subim,title=files(i),/zlog,xstyle=1,ystyle=1,xtitle='Columns',ytitle='Rows',zrange=[0.1,1e5],zstyle=1
endfor
end
