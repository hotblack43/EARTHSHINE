 ;--------------------------------
 common thetaflags,iflag_theta,radii,theta,xline,yline
 openr,1,'listtodo.txt'
 str=''
 while not eof(1) do begin
     iflag_theta=1
     readf,1,str
     print,str
     if (str eq 'stop' or str eq 'STOP') then GOTO,stop
     im=readfits(str,h)
     get_time,h,JD
     gofindradiusandcenter_fromheader,h,x0,y0,radius
     print,abs(x0-255),abs(y0-255)
     if (abs(x0-255) lt 80 and abs(y0-255) lt 80) then begin
         ;..................
	imethod=1	; i.e. median of annulus-segments
         use_cusp_angle_build_fan,im,x0(0),y0(0),radius,rad,line,imethod
         plot,rad,line,title=str
	imethod=2	; i.e. mean of annulus-segments
         use_cusp_angle_build_fan,im,x0(0),y0(0),radius,rad,line,imethod
         oplot,rad,line,color=fsc_color('red')
	imethod=3	; i.e. mean halfmedian of annulus-segments
         use_cusp_angle_build_fan,im,x0(0),y0(0),radius,rad,line,imethod
         oplot,rad,line,color=fsc_color('green')
         endif
     endwhile
 STOP:
 close,1
 end
 
