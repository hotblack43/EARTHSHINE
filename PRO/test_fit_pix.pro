PRO FLIP,array
; will put last row first, first row last etc in array
array=REVERSE(array,2)
return
end

filename='C:\MOON\pix1.bmp'
    im=read_bmp(filename)
    im=reform(im(0,*,*))        ;   grab one color of the picture
            FLIP,im
                help,im
                b=[-3.d0,211.d0,71.d0,95.d0,369.d0,174.d0,0.d0]    ;   Initial guess for fit parameters
    res=PT_GAUSS2DFIT(im,b)
    print,b
    contour,im,xrange=[b(4)-20,b(4)+20],yrange=[b(5)-20,b(5)+20],/cell_fill,xstyle=1,ystyle=1
    oplot,[b(4),b(4)],[b(5),b(5)],psym=1
 end