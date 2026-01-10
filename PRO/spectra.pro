PRO shadow_project,image,angle,shadow
;
l=size(image,/dimensions)
ncols=l(0)
nrows=l(1)
diag_len=nrows/cos((90.-angle)*!dtor)
openw,34,'temp.slice'
for i=0,ncols-1,1 do begin
	sum=0.0
	for r=0.0,diag_len,1.0 do begin
		x=i+r*cos(angle*!dtor)
		y=r*sin(angle*!dtor)
		x=max([0,x])
		x=min([ncols-1,x])
		y=max([0,y])
		y=min([ncols-1,y])
		sum=sum+image(x,y)
	endfor
	printf,34,sum
endfor
close,34
data=get_data('temp.slice')
shadow=reform(data(0,*))
return
end

PRO get_angle,im,angle
!P.MULTI=[0,1,1]
contour,im,/cell_fill,nlevels=51
cursor,a,b
wait,1
print,a,b
cursor,c,d
wait,1
print,c,d
angle=atan((d-b)/(c-a))/!dtor
print,'Angle=',angle
return
end

file1='spectrum1.jpg'
read_jpeg,file1,im1
;
tot_im1=total(im1,1)
rotated_im1=rot(tot_im1,60)
get_angle,rotated_im1,angle
slice=rotated_im1(115:602,139:199)
shadow_project,slice,angle,shadow
!P.multi=[0,1,2]
plot,shadow,title='Spectrum 1',charsize=2,xtitle='Dispersion direction'
;
file2='spectrum2.jpg'
read_jpeg,file2,im2
;
tot_im2=total(im2,1)
rotated_im2=rot(tot_im2,60)
slice=rotated_im2(115:602,139:199)
shadow_project,slice,angle,shadow
plot,shadow,title='Spectrum 2',charsize=2,xtitle='Dispersion direction'
end
