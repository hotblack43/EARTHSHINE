

PRO get_flat,l,flat
flat=(dindgen(l)/l(0)/l(1)+1)+dist(l)/100.
flat=flat*flat
flat=flat/mean(flat,/double)/100.0d0+1.0d0
flat=flat/mean(flat,/double)

return
end

PRO smear_images,im,Mdec,Mha,flat

l=size(im,/dimensions)
get_flat,l,flat
x=total(im,1,/double)
Mdec=rebin(rebin(x,l(0)*l(1)),l(0),l(1))*flat
y=total(im,2,/double)
Mha=transpose(rebin(rebin(y,l(0)*l(1)),l(1),l(0)))*flat
return
end


dark=readfits('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\AUSTRALIAMOON\sydneydark.fit',/silent)
count=0
for inum=180,220,1 do begin
name='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\AUSTRALIAMOON\'+strcompress('moon20060731.00000'+string(inum)+'.FIT',/remove_all)
im=readfits(name,/silent)
im=im-dark
smear_images,im,Mdec,Mha,origflat

amask=(Mdec*0.0d0)+1.0d0
flat=mflat_make_flat( Mdec, Mha, amask)
surface,(flat-origflat)/origflat,charsize=3
print,mean(flat-origflat),stddev(flat-origflat)
if (count eq 0) then sum=flat-origflat
if (count gt 0) then sum=[[[sum]],[[flat-origflat]]]
count=count+1
endfor
flattest=median(sum,dimension=3)
surface,flattest,charsize=3,zrange=!Z.crange
print,mean(flattest),stddev(flattest),' * '
end