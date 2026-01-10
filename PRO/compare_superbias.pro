c=readfits('biasp.fits')
c8=readfits('biaspr8.fits')
p=readfits('bestDC.fits')
imagej=readfits('imagej_meanoftwo.fits')
cp_diff=(c-p)/p*100.
c8p_diff=(c8-p)/p*100.
ip_diff=(imagej-p)/p*100.
print,'Chris & Peter differ by: ',mean(cp_diff),' %.'
print,'Chris r*8 & Peter differ by: ',mean(c8p_diff),' %.'
print,'imagej and Peter differ by:',mean(ip_diff),' %.'
end
