files=file_search('/data/pth/MTSAT/2012_*',count=n)
files=file_search('~/Desktop/epic_*',count=n)
cg=[]
for i=0,n-1,1 do begin
read_jpeg,files(i),im
l=size(im)
if (l(0) eq 3) then im=avg(im,0)
xy=centroid(im)
contour,im,/isotropic
cg=[[cg],[xy]]
for k=0,i,1 do begin
oplot,[cg(0,k),cg(0,k)],[cg(1,k),cg(1,k)],psym=7,color=fsc_color('red')
endfor
endfor
write_jpeg,'earthimage.jpg',tvrd(/TRUE),/TRUE
end
