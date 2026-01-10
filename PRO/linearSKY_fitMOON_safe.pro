
PRO MESHGRID,N,M,X,Y
;+
; PRO MESHGRID,N,M,X,Y calculates two arrays, X
; and Y that can be used to calculate and plot a 2D function.
;
; N and M can be either positive integers or vectors. If they are
; vectors then N is used as the rows of X and M is used as the columns of
; Y. If they are integers then the rows of X are IndGen(N) and the columns
; of Y are Indgen(M).
;
; Example 1
; MESHGRID,31,31,X,Y
; X=(X-15)/2.
; Y=(Y-11)/3.
; Z=EXP(-(X^2+Y^2))
; SURFACE,Z
;
; Example 2
; MESHGRID,[2,4,6],[3,5,7,9],X,Y
; creates two arrays of size 3x4 with the X array containg four rows
; with [2,4,6] and Y with columns [3,5,7,9]'.
;
; HISTORY:
; Originated by Harvey Rhody September 17, 1997.
; Revised April 2001 to accomodate vectors for N and M.
;-

IF N_ELEMENTS(N) EQ 1 THEN VN=INDGEN(N) ELSE VN=N
IF N_ELEMENTS(M) EQ 1 THEN VM=INDGEN(M) ELSE VM=M

LN=N_ELEMENTS(VN)
LM=N_ELEMENTS(VM)

X=VN#REPLICATE(1,LM)
Y=VM##REPLICATE(1,LN)


END

FUNCTION CircleHoughLink,xpts,ypts,THRESHOLD=thresh,NCIRCLES=ncircles,$
	XBINS=N,YBINS=M,HOUGH_MATRIX=A1,FINAL_MATRIX=A,H_MATRIX=H,$
	VERBOSE=verbose,RADIUS=radius,XMAX=xmax,$
	YMAX=ymax,NHD_RAD=nhd,NTHETA=ntheta
;+
;RESULT=CircleHoughLink(xpts,ypts,RADIUS=radius) finds circles in
;sets of points whose coordinates are given by xpts,ypts and whose
;radius matches the list of possible radii in the array RADIUS. The funcion
;uses the circle Hough transform (CHT) and is controlled by a number of keyword
;parameters.
;
;RESULT is an array of anonymous structures with the following tags
;and initial values:
;
;Index:-1L			Each line has a unique index [1,2,...,ncircles]
;Cx:0.0				X coordinate of center
;Cy:0.0				Y coordinate of center
;R:0.0				Radius of the circle
;Location:0L}		The location in the Hough Parameter matrix
;
;EXAMPLE
;Suppose that IMG is a binary image. An image B of boundary
;points that describe object boundaries can be found by erosion
;with a structuring element S. The circle descriptions of the
;boundaries can be found and plotted as an overlay on the
;image. If we assume a known radius R then use the following.
;
;S=REPLICATE(1,3,3)
;B=image AND NOT ERODE(IMG,S)
;imSiz=SIZE(B)
;WINDOW,/FREE,XSIZE=imSiz[1],YSIZE=imSiz[2],TITLE='Edges'
;circles=CircleHoughLink(x,y,RADIUS=R)
;ncircles=MAX(circles.Index) ;Find the number of lines found.
;theta=FLTARR(101)*!pi/50
;FOR k=0,circles-1 DO PLOTS,circles[k].Cx+circles[k].R*cos(theta),$
;	circles[k].Cy+circles[k].R*sin(theta)
;
;DESCRIPTION AND KEYWORDS
;The algorithm utilizes the parametric form of the description of
;a circle to search for the center. The radius is assumed to be
;given. The returned structure contains the centers and radius
;of each circle found.
;
;KEYWORDS: XBINS, YBINS, NTHETA, HOUGH_MATRIX
;The (Cx,Cy) cells correspond to a matrix A, which
;accumulates the count of the number of parametric curves in
;parametric space that pass through each cell. The number of
;cells can be set through the keywords XBINS and YBINS.
;The default values are XBINS=100, YBINS=100. The
;accumulated A matrix can be accessed via the keyword
;HOUGH_MATRIX. A[i,j] gives the number of circles that have
;Cx and Cy values that correspond to cell A[i,j].
;The maximum values may be given by the keywords XMAX and YMAX.
;The default is XMAX=YMAX=1000. The Hough bins are "filled" by tracing out
;a locus of points around each (x,y) point. The number of points
;in the circular locus in NTHETA (default 100).
;;
;KEYWORDS: THRESHOLD, ncircles
;The search for circles progresses by cycling through the A matrix
;and using a current maximum value to identify a parameter cell.
;The search continues until it finds NCIRCLES or there are no
;remaining cell counts that exceed THRESHOLD. The default value
;of NCIRCLES=1 and the default THRESHOLD=0.9*MAX(A). The actual
;number of circles returned is N_ELEMENTS(Result), which may be less
;than NCIRCLES.
;
;KEYWORDS: NHD_RAD, FINAL_MATRIX
;The search algorithm provides some parameters that facilitate
;weeding out unwanted circles. Each time a cell of A is used then
;that element is set to a value of -2 and the cells in a
;neighborhood of size NHD_RAD in each direction are set to -1. This
;marks the central cell and the neighborhood and prevents any A-cells
;in the neighborhood from being used. The default value is NHD_RAD=1.
;The cells are blocked out in the neighborhood in the same radius
;plane as the selected cell. Cells are not blocked out across
;radius planes.
;
;The FINAL_MATRIX keyword can be used to access the last parameter
;count matrix used by the algorithm just before it exited. This is
;useful in examining the parameter combinations that have
;contributed to the circles that were returned. A visual presentation
;can be constructed as in the code below.
;
;KEYWORD VERBOSE
;Setting VERBOSE=1 produces a printout that summarizes each circle as the
;search progresses. The default is VERBOSE=0.
;
;HISTORY
;H. Rhody, October, 1999 for Digital Image Processing class.
;-

;Set up defaults
IF KEYWORD_SET(ncircles) EQ 0 THEN ncircles=1
IF N_ELEMENTS(N) EQ 0 THEN N=100
IF N_ELEMENTS(M) EQ 0 THEN M=100
N=LONG(N) & M=LONG(M) & MN=M*N
IF KEYWORD_SET(ntheta) EQ 0 THEN ntheta=100
IF KEYWORD_SET(verbose) EQ 0 THEN verbose=0
;Set up the limits of the search in the X and Y directions.
IF KEYWORD_SET(xmax) EQ 0 THEN xmax=1000
IF KEYWORD_SET(ymax) EQ 0 THEN ymax=1000
;Construct the neighborhood description
IF KEYWORD_SET(nhd) EQ 0 THEN nhd=1
meshgrid,2*nhd+1,2*nhd+1,xNbrVec,yNbrVec
xNbrVec=xNbrVec-nhd
yNbrVec=yNbrVec-nhd

;If no list of radius values is given, then return with an error message
NR=N_ELEMENTS(radius)
IF NR LE 0 THEN BEGIN
	PRINT,'Function cirleHoughLink requires at least one value'
	PRINT,'for a radius function set via keyword RADIUS.'
	RETURN,-1
ENDIF ELSE BEGIN
;Set up the parameter count and point array matrices. NR is the
;number of radius values.
A=INTARR(N,M,NR)

;Define an array of structures to be filled in by the search.
;The index fields are initialized to -1 to facilitate finding
;the number of circles actually located should the search
;fall short.
;
;The anonymous structure has the tag names
;Index:-1L			Each line has a unique index [1,2,...,ncircles]
;Cx:0.0				X coordinate of center
;Cy:0.0				Y coordinate of center
;R:0.0				Radius of the circle
;Location:0L}		The location in the Hough Parameter matrix

circles=REPLICATE({Index:-1L,Cx:0.0,Cy:0.0,R:0.0,Location:0L},ncircles)

; If the lengths of the coordinate vectors are not equal,
; then use the smaller number of points.
NPTS=MIN([N_ELEMENTS(xpts),N_ELEMENTS(ypts)])
xpts=xpts[0:NPTS-1] & ypts=ypts[0:NPTS-1]

; Construct the theta vector of length N and the associated
; index vector.
theta=2*FINDGEN(ntheta)*!PI/(ntheta-1); Number of points in circle locus
radiusmax=MAX(radius)
deltaX=FLOAT(xmax+2*radiusmax)/N
deltaY=FLOAT(ymax+2*radiusmax)/M

IF KEYWORD_SET(VERBOSE) THEN $
PRINT,FORMAT=$
	'("Center Location Limits: [",f6.1,",",f6.1,"] deltaX=",g8.4," deltaY=",g8.4)',$
	[xmax+2*radiusmax,ymax+2*radiusmax,deltaX,deltaY]

; Construct the count in parameter space, for each point
; p=(x,y) provided in the function call.
FOR ir=0,NR-1 DO BEGIN
	Rcostheta=radius[ir]*cos(theta)
	Rsintheta=radius[ir]*sin(theta)
FOR p=0L,NPTS-1 DO BEGIN
	;Calculate the Cx and Cy coordinates for the circular
	;locus of points at radius[ir] R around each (x,y). Shift
	;each value by (R,R) so it does not go negative.
	ka=FIX((xpts[p]-Rcostheta + radiusmax)/deltaX)
	kb=FIX((ypts[p]-Rsintheta + radiusmax)/deltaY)
	ia=WHERE(ka GE 0 AND ka LT N AND kb GE 0 AND kb LT M)
	ka=ka[ia]
	kb=kb[ia]
	;Calculate the array index vector
	k=ka+kb*N + ir*MN	; Get the array index of each (a,b) pair
	A[k]=A[k]+1	; INCREMENT the counting matrix at each point.
ENDFOR
ENDFOR
;Preserve the original counting matrix to return if it is requested
;with the HOUGH_MATRIX keyword.
A1=A


circlesFound=0
IF KEYWORD_SET(thresh) EQ 0 THEN thresh=0.9*MAX(A)
REPEAT BEGIN
	HA=MAX(A,kq) & kq=kq[0]; Get the index kp of the peak
	ir=kq/MN ;Index of radius plane in A matrix
	kp=kq MOD MN
	xp=kp MOD N	;The horizontal coordinate of the peak
	yp=kp/N		;The vertical coordinate of the peak
	tnbrs=xp+xNbrVec ;The coordinates of the neighbors
	rnbrs=yp+yNbrVec
	;Check that the neighbors are within the array boundaries.
	inbrs=WHERE(tnbrs GE 0 AND tnbrs LT N AND rnbrs GE 0 AND rnbrs LT M)
	nbrs=tnbrs[inbrs]+N*rnbrs[inbrs]; Indices of valid neighbors
	;The neighbors will be removed later if the cell is accepted.

	;Remember the value at the peak then set that array value to
	;zero.
	peak=A[kq]
	A[kq]=0

	; Find the Cx and Cy for the Hough index kp.
	X1=(kp MOD N)*deltaX - radiusmax
	Y1=kp/N*deltaY - radiusmax

	circlesFound=circlesFound+1
	IF verbose GE 1 THEN BEGIN
	PRINT,' '
	PRINT,'===================================================='
	PRINT,'Circle Number ',circlesFound
	PRINT,'Radius=',radius[ir]
	PRINT,FORMAT='("Hough Index=",i7,"  Number of points=",i7)',[kp,peak]
	PRINT,FORMAT='("Center=[",f6.2,",",f6.2,"]")',[X1,Y1]
	ENDIF
;Keep the data in the structure.
	circles[circlesFound-1].Index=circlesFound
	circles[circlesFound-1].Cx=X1
	circles[circlesFound-1].Cy=Y1
	circles[circlesFound-1].R=radius[ir]
	circles[circlesFound-1].Location=kp
	;Set the neighborhood values to -1 and the point value
	;to -2 to mark them. These values will not be used
	;again in the search.
	A[nbrs]=-1
	A[kp]=-2

ENDREP UNTIL circlesFound GE ncircles OR peak LT thresh
RETURN,circles[0:circlesFound-1]
ENDELSE
END

PRO HOUGH_FIT_MOON,im,x0,y0
common radiusguess,r
;---------------------------------
edge=sobel(im)
im_to_use=median(edge,7)
imSiz=SIZE(im_to_use)
		kpts=WHERE(im_to_use gt median(im_to_use))
            xpts=kpts MOD imSiz[1]
            ypts=kpts/imSiz[1]
circles=CircleHoughLink(xpts,ypts,RADIUS=R,VERBOSE=0)
help,circles,/structure
ncircles=MAX(circles.Index) ;Find the number of lines found.
print,ncircles
theta=findgen(101)*!pi/50.
FOR k=0,ncircles-1 DO begin
	;oplot,circles[k].Cx+circles[k].R*cos(theta),circles[k].Cy+circles[k].R*sin(theta),psym=3
endfor

x0=circles[0].Cx
y0=circles[0].Cy
return
end

FUNCTION petersfunc1,a
;
;	A circle is fitted
;
common moon,image
common keep,bestcorr
x0=a(0)
y0=a(1)
r=a(2)
corr=evaluate1(image,x0,y0,r)
if (corr lt bestcorr) then begin
    print,format='(a,3(1x,f8.3),1x,f8.3)','In petersfunc1:',a,corr
    bestcorr=corr
endif
return,corr
end


PRO fit_moon1,file,orgimage,x0_in,y0_in,r_in,x0,y0,r
; PURPOSE   - to find the center and radius of the Moon in the image orgimage
; INPUTS    - file,x0_in,y0_in,r_in: filename and initial guesses of center and radius
; OUTPUTS   - x0,y0,r
;----------------------------------------------------
;	Note - fits a circle
;----------------------------------------------------
common moon,image
x0=x0_in
y0=y0_in
r=r_in
image=orgimage
tot1=total(image)
despeckle,image
tot2=total(image)
print,'despeckling removed ',tot1-tot2
;
a=[x0,y0,r]
xi=[[1,0,0],[0,1,0],[0,0,1]]
ftol=1.e-8
POWELL,a,xi,ftol,fmin,'petersfunc1'
;
x0=a(0)
y0=a(1)
r=a(2)
;

	POWELL,a,xi,ftol,fmin,'petersfunc1'

;
return
end

PRO letsdocircle,file,image,x00,y00,radius,x0,y0,r,bestcorr,orgimage,imnum,imstart
common angles,angle_Grimaldi,angle_crisium
common facts,probableradius,probablex00,probabley00

fit_moon1,file,image,x00,y00,radius,x0,y0,r
if (bestcorr gt 10) then begin
	tvscl,orgimage
;	print,'CLICK ON LEFT EDGE OF MOON.'
;	cursor,aL,bL,/device
;	wait,0.5
;	print,'CLICK ON RIGHT EDGE OF MOON.'
;	cursor,aR,bR,/device
;	r=abs(aR-aL)/2.0
;	x00=aL+r
;	y00=(bL+bR)/2.
;make_row_sum_plot,orgimage,x00,y00,radius
;stop
radius=probableradius
x00=probablex00
y00=probabley00
	fit_moon1,file,image,x00,y00,radius,x0,y0,r
endif
x00=x0
y00=y0
radius=r
fmt='(a,3(1x,f8.3))'
printf,55,format=fmt,'Centre and radius: ',x00,y00,radius
;save_fitted_pars_circle,file,x00,y00,radius
;save_lastfit_circle,file,x00,y00,radius
;
; First look at Grimaldi
;
iregion='Grimaldi'
;
; find Feature
;

find_feature,orgimage,image,x0,y0,r,angle_Grimaldi
;
; find the scattered light in the relevant cone
;
make_fan,orgimage,image,x0,y0,r,angle_Grimaldi,file,iregion
;
; Then look at Crisium
;
iregion='Crisium'
;
; find Feature
;

find_feature,orgimage,image,x0,y0,r,angle_crisium
;
; find the scattered light in the relevant cone
;
make_fan,orgimage,image,x0,y0,r,angle_crisium,file,iregion
;
return
end

FUNCTION evaluate1,image,x0,y0,r
;
;	Evaluate correlation between image and circle
;
make_circle,x0,y0,r,x,y
image2=image
image2(x,y)=max(image)
image3=image*0.0
image3(x,y)=1.0
;corr=abs(1./correlate(image3,image,/double))
corr=abs(1d3/total(image3*image+10.))
tvscl,image+image3
return,corr
end

FUNCTION get_data,filename
data = READ_ASCII(filename)
get_data=data.field1
return,get_data
end

PRO make_ellipse,x0,y0,r1,r2,x,y
angle=findgen(3000)/3000.*360.0
x=fix(x0+r1*cos(angle*!dtor))
y=fix(y0+r2*sin(angle*!dtor))
return
end

FUNCTION evaluate2,image,x0,y0,r1,r2
make_ellipse,x0,y0,r1,r2,x,y
image2=image
image3=image*0.0
image2(x,y)=max(image)
image3(x,y)=1.0
;corr=abs(1./correlate(image3,image,/double))
number=total(image3*image)
corr=abs(1d3/number)
tvscl,image+image3
return,corr
end

PRO find_feature,orgimage,image,x0,y0,r,angle
tvscl,orgimage
print,'CLICK ON FEATURE!!'
cursor,a,b,/device
plots,[a,a],[b,b],psym=7,/device
plots,[x0,x0],[y0,y0],psym=6,/device
angle=atan((y0-b)/(x0-a))/!dtor
print,'Angle found was:',angle,' degrees',(y0-b)/(x0-a)
return
end

PRO make_fan,orgimage,image,x0,y0,r,angle,file,iregion
;	help,orgimage,image,x0,y0,r,angle,file,iregion
;
common info,JD,imnum
common results,corrected_im
if_display=1    ; want TVSCL???
; now make fan...
l=size(image,/dimensions)
radii=fltarr(l)
theta=fltarr(l)
xline=intarr(l)
yline=intarr(l)
for icol=0,l(0)-1,1 do begin
for irow=0,l(1)-1,1 do begin
    xline(icol,irow)=icol
    yline(icol,irow)=irow
    radii(icol,irow)=sqrt((icol-x0)^2+(irow-y0)^2)
    theta(icol,irow)=atan((irow-y0)/(icol-x0))/!dtor
endfor
endfor
if (iregion eq 'Grimaldi') then begin
    step=6.8976
    radstep=r/27.54
    radstep=r/31.
endif
if (iregion eq 'Crisium') then begin
    step=6.8976
    radstep=r/27.54
    radstep=r/31.
endif

for theta_lo=angle-step/2.05,angle+step/2.05,step do begin
    theta_hi=theta_lo+step
    openw,44,'temp.dat'
    for rad_var=r*0.65,1.5*r,radstep do begin
    ;print,theta_lo,rad_var
        mask=intarr(l(0),l(1))*0
        if (iregion eq 'Grimaldi') then begin
            idx=where(theta gt theta_lo and theta le theta_hi and radii lt rad_var+radstep and radii ge rad_var and xline lt x0)
            grimaldi_idx=where(theta gt theta_lo and theta le theta_hi and xline lt x0)
        endif
        if (iregion eq 'Crisium') then begin
            idx=where(theta gt theta_lo and theta le theta_hi and radii lt rad_var+radstep and radii ge rad_var and xline gt x0)
            crisium_idx=where(theta gt theta_lo and theta le theta_hi and xline gt x0)
        endif
        numbers=n_elements(idx)
        if (idx(0) ne -1) then mask(xline(idx),yline(idx))=1
        if (if_display eq 1) then tvscl,orgimage+mask*20000.
        kdx=where(mask eq 1)
        value=-911
        std=-911
        if (kdx(0) ne -1 and numbers gt 2) then begin
            value=median(orgimage(kdx))
            std=stddev(orgimage(kdx))/sqrt(n_elements(kdx)-1)
            print,theta_lo,rad_var,value,std,numbers
            printf,44,rad_var+radstep/2.,value,std
        endif
        wait,1
    endfor
            if (iregion eq 'Grimaldi') then kdx=where(theta gt theta_lo and theta le theta_hi and radii lt r and radii ge r-r/20. and xline lt x0)
            if (iregion eq 'Crisium') then kdx=where(theta gt theta_lo and theta le theta_hi and radii lt r and radii ge r-r/20. and xline gt x0)
            region=median(orgimage(kdx))
    close,44
    data=get_data('temp.dat')
    rrr=reform(data(0,*))
    lys=reform(data(1,*))
    std=reform(data(2,*))
    idx=where(lys gt -911)
    rrr=rrr(idx)
    lys=lys(idx)
    std=std(idx)
set_plot,'ps
device,filename=strcompress('fan'+iregion+'.ps',/remove_all)
    plot,rrr,lys,psym=-7,xtitle='Distance from Moon center (pixels)',ytitle='Counts',charsize=1.9,ystyle=1,title='Angle ='+string(theta_lo)
    oploterr,rrr,lys,std
    plots,[r,r],[!Y.CRANGE],linestyle=2
    idx=where(rrr gt r*1.05 and rrr lt 1.45*r)
    meanx=mean(rrr(idx))
    res=linfit(rrr(idx),lys(idx),yfit=lysmodel,sigma=sigs,chisq=chi2,/double)
    oplot,rrr(idx),lysmodel,thick=3
    oplot,rrr,rrr*res(1)+res(0),thick=1
    xxx=indgen(l(0))
    uncertainty=sqrt(sigs(0)^2+(sigs(1)*(xxx-meanx))^2)
    oplot,xxx,xxx*res(1)+res(0)+uncertainty,linestyle=1
    oplot,xxx,xxx*res(1)+res(0)-uncertainty,linestyle=1
device,/close
set_plot,'win
endfor
;predict scattered light at patch
predscat=res(0)+res(1)*(r-radstep/2.)
print,'predicted scatter at patch:',predscat
fmt='(a,4(1x,f13.6),1x,a,f12.1,2(1x,a,f12.4))'
print,format=fmt,iregion+': ',res,sigs,' chi^2=',chi2,'RAWREG=',region,'CORSCAT=',region-predscat,file
printf,55,format=fmt,iregion+': ',res,sigs,' chi^2=',chi2,'RAWREG=',region,'CORSCAT=',region-predscat
if (iregion eq 'Grimaldi') then begin
        openw,72,'Grimaldi_Crisium.temp'
        printf,72,region-predscat
        close,72
endif
if (iregion eq 'Crisium') then begin
        openr,72,'Grimaldi_Crisium.temp'
        readf,72,grimaldi_value
        close,72
        ratio=grimaldi_value/(region-predscat)
        printf,55,format='(a,f9.4)','Grimaldi/Crisium:',ratio
        printf,75,format='(i4,1x,d20.6,6(1x,f9.4))',1,1,grimaldi_value,region-predscat,ratio,x0,y0,r
endif
; calculate the image minus the predicted scatter, in the cone
if (iregion eq 'Grimaldi') then begin
    corrected_im=double(orgimage)
    corrected_im(grimaldi_idx)=corrected_im(grimaldi_idx)-(res(0)+res(1)*radii(grimaldi_idx))
endif
if (iregion eq 'Crisium') then begin
    corrected_im(crisium_idx)=corrected_im(crisium_idx)-(res(0)+res(1)*radii(crisium_idx))
endif
return
end


PRO fit_moon2,file,orgimage,x0_in,y0_in,r1_in,r2_in,x0,y0,r1,r2
; PURPOSE   - to find the center and radii of the Moon in the image orgimage
; INPUTS    - file,x0_in,y0_in,r1_in,r2_in: filename and initial guesses of center and radii
; OUTPUTS   - x0,y0,r1,r2
;----------------------------------------------------
; 	Note - fits an ellipse
;----------------------------------------------------
common moon,image
x0=x0_in
y0=y0_in
r1=r1_in
r2=r2_in
image=orgimage
;
a=[x0,y0,r1,r2]
xi=[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
ftol=1.e-6
POWELL,a,xi,ftol,fmin,'petersfunc2'
;print,xi
;
x0=a(0)
y0=a(1)
r1=a(2)
r2=a(3)
;
return
end


PRO letsdoellipse,file,image,x00,y00,radius1,radius2,x0,y0,r1,r2,bestcorr,orgimage,imnum,imstart
common angles,angle_Grimaldi,angle_crisium

fit_moon2,file,image,x00,y00,radius1,radius2,x0,y0,r1,r2
if (bestcorr gt 5) then begin
    tvscl,orgimage
    print,'CLICK ON LEFT EDGE OF MOON.'
    cursor,aL,bL,/device
    wait,0.5
    print,'CLICK ON RIGHT EDGE OF MOON.'
    cursor,aR,bR,/device
    r=abs(aR-aL)/2.0
    x00=aL+r
    y00=(bL+bR)/2.
    fit_moon2,file,image,x00,y00,radius1,radius2,x0,y0,r1,r2
endif
x00=x0
y00=y0
radius1=r1
radius2=r2
fmt='(a,4(1x,f8.3))'
printf,55,format=fmt,'Centre and radii : ',x00,y00,r1,r2
;save_fitted_pars_ellipse,file,x00,y00,radius1,radius2
;save_lastfit_ellipse,file,x00,y00,radius1,radius2
;
; First look at Grimaldi
;
iregion='Grimaldi'
;
; find Feature
;

find_feature,orgimage,image,x0,y0,(radius1+radius2)/2.,angle_Grimaldi
;
; find the scattered light in the relevant cone
;
make_fan,orgimage,image,x0,y0,(radius1+radius2)/2.,angle_Grimaldi,file,iregion
;
; Then look at Crisium
;
iregion='Crisium'
;
; find Feature
;

find_feature,orgimage,image,x0,y0,(radius1+radius2)/2.,angle_crisium
;
; find the scattered light in the relevant cone
;
make_fan,orgimage,image,x0,y0,(radius1+radius2)/2.,angle_crisium,file,iregion
;
return
end

PRO get_lastfit_circle,file,x00,y00,radius
x00=0.0
y00=0.0
radius=0.0
openr,72,'lastfit_circle'
readf,72,x00,y00,radius
print,'Opened lastfit_circle, found: x00,y00,radius=',x00,y00,radius
close,72
return
end

PRO get_lastfit_ellipse,file,x00,y00,radius1,radius2
x00=0.0
y00=0.0
radius1=0.0
radius2=0.0
openr,72,'lastfit_ellipse'
readf,72,x00,y00,radius1,radius2
print,'Opened lastfit_ellipse, found:x00,y00,radius1,radius2=',x00,y00,radius1,radius2
close,72
return
end

PRO locate_filter_edge_mask,image,maskleft,maskright
contour,image
print,'Click slightly left of left edge of filter'
cursor,ml,dummy
wait,0.5
print,'Click slightly right of right edge of filter'
cursor,mr,dummy
wait,0.5
maskleft=ml
maskright=mr
return
end

PRO make_circle,x0,y0,r,x,y
angle=findgen(1000)/1000.*360.0
x=fix(x0+r*cos(angle*!dtor))
y=fix(y0+r*sin(angle*!dtor))
; make another layer outside first
ran=randomu(seed)
x=[x,fix(x0+(r+1)*cos(angle*!dtor+ran))]
y=[y,fix(y0+(r+1)*sin(angle*!dtor+ran))]
; make another layer inside other two
x=[x,fix(x0+(r-1)*cos(angle*!dtor-ran))]
y=[y,fix(y0+(r-1)*sin(angle*!dtor-ran))]
return
end


PRO generateJD,obsdate,obstime,JD
year=fix(strmid(strmid(obsdate,11,10),0,4))
month=fix(strmid(strmid(obsdate,11,10),5,2))
dd=fix(strmid(strmid(obsdate,11,10),8,2))
hh=fix(strmid(strmid(obstime,11,8),0,2))
mm=fix(strmid(strmid(obstime,11,8),3,2))
ss=fix(strmid(strmid(obstime,11,8),6,2))
JD=julday(month,dd,year,hh,mm,ss)
return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;             LUNAR FEATURE PHOTOMETRIC ANALYSER
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
common keep,bestcorr
common info,JD,imnum
common facts,probableradius,probablex00,probabley00
common results,corrected_im
common radiusguess,r
;--------------------------------------
if_rebin=0	; set to 1 if rebinning of image is needed
rebin_factor=1.
probableradius=409.*rebin_factor
probablex00=300.*rebin_factor
probabley00=500.*rebin_factor

;--------------------

maskleft=450*rebin_factor   ; column to start image rescaling at, from left
scalefactor=1.   ; factor rescale bright side by
;--------------------------------------
openw,75,'tabulated_output.dat'
printf,75,'image_number    JD          GRIM   reg-scat     ratio      x0        y0       r'

fit_form=2	; fit Moon's rim with an ellipse
fit_form=1	; fit Moon's rim with a circle
file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\stacked_ChrisAlg_PeterStack_349_float.fit'
file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\May25\May25\IMG60.FIT'
file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\Moon_simulated_53.FIT'

;
;
openw,55,'Crisium_Grimaldi_fits.results'

printf,55,'================================================================================='
printf,55,'  '
bestcorr=1e20
rdfits_struct, file, struct, /silent
results=readfits(file,header)
image=struct.im0
R=[409.]
HOUGH_FIT_MOON,image,probablex00,probabley00
print,'Found Moon centre:',probablex00,probabley00
l=size(image,/dimensions)
if (if_rebin eq 1) then image=congrid(image,l(0)*rebin_factor,l(1)*rebin_factor)
l=size(image,/dimensions)

ncols=l(0)
nrows=l(1)
window,0,xsize=ncols*rebin_factor,ysize=nrows*rebin_factor
tvscl,image
;mask the bright part of the image
image(maskleft:l(0)-1,*)=image(maskleft:l(0)-1,*)/scalefactor
write_bmp,'Moon.bmp',image
orgimage=image
; edge-enhance the image
image=sobel(image)
median_sobel=median(image)
std_sobel=stddev(image)
idx=where(image gt median_sobel+3.0*std_sobel)
jdx=where(image le median_sobel+3.0*std_sobel)
image(idx)=1.0
image(jdx)=0.0
l=size(image,/dimensions)
; guess at parameters...
x00=probablex00
y00=probabley00
radius=probableradius
radius1=probableradius
radius2=probableradius
; guess by making row sum and looking for edge...
;make_row_sum_plot,image,x00,y00,radius
;-------------------------------------------------------------------
; find center and rim by Powell's method....
;
if (fit_form eq 1) then begin
	letsdocircle,file,image,x00,y00,radius,x0,y0,r,bestcorr,orgimage,imnum,imstart
endif	; end of fitting circle
if (fit_form eq 2) then begin
	letsdoellipse,file,image,x00,y00,radius1,radius2,x0,y0,r1,r2,bestcorr,orgimage,imnum,imstart
endif	; end of fitting ellipse
close,55
close,75
; write corrected image
writefits,'MAy25_IMG60_linearskyremoved.fit',double(corrected_im)
end
