; generate a padded image from an input image
file='sydney_2x2.fit'

im=readfits(file)
bias=min(im)	; remove any known pedestals
print,'Smallest value in image was:',bias,' and I shall remove such a pedestal.'
blank=im*0.0d0
row1=[blank,blank,blank]
row2=[blank,im-bias,blank]
row3=row1
imout=[[row1],[row2],[row3]]
writefits,strcompress('padded_'+file,/remove_all),imout
help,imout
end