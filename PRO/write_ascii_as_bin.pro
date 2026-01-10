; utility to convert an ascii map of albedo into a binary file
X = read_ascii('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\Eshine\data_eshine\Earth.1d.map',data_start=0)
l=size(X.field001,/dimensions)
openw,11,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\Eshine\data_eshine\Earth.1d.map.binary'
writeu,11,l
writeu,11,X.field001
close,11
end