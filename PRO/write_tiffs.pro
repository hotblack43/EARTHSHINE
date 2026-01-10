file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\stacked_new_first99_float.FIT'
im=double(readfits(file))
write_jpeg,'im.jpg',bytscl(alog(im))+bytscl(im)
writefits,'im.fit',bytscl(alog(im))+bytscl(im)
end