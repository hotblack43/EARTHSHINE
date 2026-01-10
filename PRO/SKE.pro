DF=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455641/meanhalfmedian_dark.fits')
im=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455641/SKE.fits')
im=(im-DF)
end
