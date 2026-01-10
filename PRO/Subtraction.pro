PRO Subtraction
!Quiet=1
!Except=0

;  Input interface routine to test OIS.prg by Marc Buie
;  J. Patrick Miller, Hardin-Simmons University

;=============================================INPUT INFORMATION===========================================================;

; Set the Directory & Extension
	Path   ="/home/pth/Desktop/ASTRO/ANDOR/"
	OutPath="/home/pth/Desktop/ASTRO/ANDOR/"
;	Path   ="C:\Users\J. Patrick Miller\Desktop\Buie OIS\2. Images\"
;	OutPath="C:\Users\J. Patrick Miller\Desktop\Buie OIS\3. OIS\"

; Input the Images
    Img="" & READ,PROMPT="Image Name: "    ,Img
    Ref="" & READ,PROMPT="Reference Name: ",Ref

; Input the Image FWHM (Approximate), Light Percentage, & Chi^2 Statistics
    READ,PROMPT="Image FWHM: "              ,FWHM
    READ,PROMPT="Range of Light (Minimum):" ,LightMin
    READ,PROMPT="Chi^2 Statistic: "         ,ChiSqStat

; Input the Polynomial Degree
	READ,PROMPT="Degree of the Kernel Polynomials: ",Deg
;	IF DEGREE NE 0.0 THEN READ,PROMPT="Convolution Width: ",DELP ELSE DELP=1

; Input the Saturation Level
	READ,PROMPT="Maximum Saturation Level:",Saturate

; Input the Kernel Basis
	IBasis="" & READ,PROMPT="Gaussian Basis (Yes/No): ",IBasis
	Gaussian="DELTA" & IF STRUPCASE(IBasis) EQ "YES" THEN Gaussian="Astier"

; Input the Constant Photometric Ratio Flag
;	IRatio="" & READ,PROMPT="Use the Constant Photometric Ratio (Yes/No): ",IRatio
;	IF STRUPCASE(IRatio) EQ "YES" THEN ConstPhot="YES" ELSE ConstPhot="NO"

;=========================================================================================================================;

;=============================================SUBTRACT IMAGES=============================================================;

	IF Gaussian EQ "DELTA" THEN BEGIN
		OIS, Img,Ref,DiffImg, DEGREE=FIX(Deg),CHISQSTAT=ChiSqStat,FWHM=FWHM,MINFLUX=LightMin,PATH=Path,OUTPATH=OutPath,MAXPHOTSIG=Saturate,SAVEIT=1      ;CONSTPHOT=ConstPhot
	ENDIF ELSE BEGIN
		OIS, Img,Ref,DiffImg, DEGREE=FIX(Deg),CHISQSTAT=ChiSqStat,FWHM=FWHM,MINFLUX=LightMin,PATH=Path,OUTPATH=OutPath,GAUSSIAN=Gaussian,MAXPHOTSIG=Saturate,SAVEIT=1      ;CONSTPHOT=ConstPhot
	ENDELSE

;=========================================================================================================================;


END

