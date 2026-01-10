file='check_ped.files'
openr,1,file
w=13
i=0
listen=[]
while not eof (1) do begin
str=''
readf,1,str
print,i
bits=strsplit(str,' ',/extract)
ped=bits(0)
fname=bits(1)
im=readfits(fname)
corner=median(im(0:w,511-w:511))
print,ped,corner
listen=[[listen],[ped,corner]]
i=i+1
endwhile
close,1
end
