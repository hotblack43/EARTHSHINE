Bdome=readfits('B_superDOMEflat.fits')
Blamp=readfits('B_superLAMPflat.fits')
Bsky=readfits('B_superSKYflat.fits')
IRCUTdome=readfits('IRCUT_superDOMEflat.fits')
IRCUTlamp=readfits('IRCUT_superLAMPflat.fits')
IRCUTsky=readfits('IRCUT_superSKYflat.fits')
VE1dome=readfits('VE1_superDOMEflat.fits')
VE1lamp=readfits('VE1_superLAMPflat.fits')
VE1sky=readfits('VE1_superSKYflat.fits')
VE2dome=readfits('VE2_superDOMEflat.fits')
VE2lamp=readfits('VE2_superLAMPflat.fits')
VE2sky=readfits('VE2_superSKYflat.fits')
Vdome=readfits('V_superDOMEflat.fits')
Vlamp=readfits('V_superLAMPflat.fits')
Vsky=readfits('V_superSKYflat.fits')
im1=[Blamp,Bsky,Bdome]
im2=[Vlamp,Vsky,Vdome]
im3=[VE1lamp,VE1sky,VE1dome]
im4=[VE2lamp,VE2sky,VE2dome]
im5=[IRCUTlamp,IRCUTsky,IRCUTdome]
im=[[im1],[im2],[im3],[im4],[im5]]
writefits,'allflats.fits',im
; choose the falttest:
spawn,"cp B_superDOMEflat.fits B_superflat.fits"
spawn,"cp IRCUT_superDOMEflat.fits IRCUT_superflat.fits"
spawn,"cp VE1_superDOMEflat.fits VE1_superflat.fits"
spawn,"cp VE2_superSKYflat.fits VE2_superflat.fits"
spawn,"cp V_superLAMPflat.fits V_superflat.fits"
end
