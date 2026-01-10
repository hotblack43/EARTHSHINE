path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455641/'
dark=50.*readfits(path+'meanhalfmedian_dark.fits')
orig_im=readfits(path+'sum.fits')
orig_im=orig_im-dark
angle=0.01
a=''
while (a ne 'q') do begin
a=get_kbrd()
if (a eq 'u') then angle=angle+0.005
if (a eq 'd') then angle=angle-0.0048574
print,'Angle=',angle
im=rot(orig_im,angle)
plot,im(*,0),ystyle=1,xrange=[240,280]
oplot,im(*,511),color=fsc_color('red')
endwhile
writefits,'rotatedim.fits',im
;
end
