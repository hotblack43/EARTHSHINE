files=file_search('B-*.jpg',count=Nfiles)

read_jpeg,files(0),im1
im1=total(im1,1)
for kl=1,Nfiles-1,1 do begin
read_jpeg,files(kl),im2
im2=total(im2,1)
l=size(im1,/dimensions)
n=min([l])
im1=im1(0:n-1,0:n-1)
im2=im2(0:n-1,0:n-1)
help,im1,im2
m=n
im1use=im1
im2use=im1
        srs_idl, im1use,im2use,Ffft_tm, Ffft_rad, Ffft_radc, absF_tm, absF_rad, $
            R, Rc, IRc, maxn, IX, IY, II, y, x, polar_coord1, $
            n, m, base, pIm1, pIm2, i, j, V00, V01, V10, V11, $
            X0, X1, y0, y1, s, R1, R2, R3, R1_Real, R1_Img, scale,angle
diff=im1use-rot(shift(im2use,ix,iy),angle,1./scale,cubic=-0.5)
tvscl,im2
print,'Detected rotation and scaling:',angle,scale
print,'Detected shifts ',ix,iy
im1=im2
endfor
end


