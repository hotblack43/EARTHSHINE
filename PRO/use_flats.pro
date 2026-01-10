gain=3.78
QE=0.8
gain=1.0
QE=1.0
bias=readfits('DAVE_BIAS.fits')
files=['/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455707/2455707.7152143MLOSKYFLATMAY25VAIR.fits', '/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455707/2455707.7152889MLOSKYFLATMAY25VAIR.fits', '/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455707/2455707.7151385MLOSKYFLATMAY25VAIR.fits', '/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455707/2455707.7150639MLOSKYFLATMAY25VAIR.fits']
stack=readfits(files(0))-bias
for i=1,3,1 do begin
im=readfits(files(i))-bias
stack=[[[stack]],[[im*gain/QE]]]
endfor
help
print,stddev(stack(20,20,*))/mean(stack(20,20,*))*100.0,100./sqrt(mean(stack(20,20,*)))
end

