; $Id: //depot/idl/IDL_64/idldir/lib/obsolete/anova.pro#1 $
;
;  Copyright (c) 1991-2007, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.


    Pro ContrastH,T,M,SS, MS, Names, n, rep, DFE, unit

;ContrastH evaluates the significance of the
;contrasts contained in the 1-or 2- dim array T and
;inserts the results into the anova table under
;construction. T(i,j)= coefficient of ith mean in
;jth contrast. M/S= means to be used in contrasts,
;MS = mean square error.  Names= treatment,block,or
;interaction names n=0,1,2,3 depending on whether
;contrast is of 1-way treatments 2-way with/without
;interactions.Rep = # of replications


 S = SS
 SM=size(M)			;Size Info for Means
 if(SM(0) EQ 1) THEN  S1= SM(1) else S1= SM(1)*SM(2)


 ST=size(T)                     ; Size info for Coefficients
 C=ST(1)

 OK = testcontrast(T, unit)
 if OK EQ 0 THEN BEGIN
   printf,unit,'anova ---contrast array contains equations'
   printf,unit,'whose coefficients do not sum to 0'
   return
 ENDIF
 if OK EQ -1 then return

 if(ST(0) GT 1) Then Con=ST(2) else Con=1

 SN=Size(Names)
 if(C NE S1 ) THEN BEGIN        ; Check compatibility
   printf,unit, 'anova- Contrast has wrong size'
   Return
 ENDIF

  if(SN(0) EQ  0) THEN Name="Contrast" +  $
                            StrTrim( INDGEN(Con),2) $
  else if   (SN(1) LT Con) THEN BEGIN
   Nm=INDGEN(Con)
   Name=[Name,"Contrast" +StrTrim(Nm(SN:Con-1))]
   ENDIF else Name=Names


 if(ST(0) EQ 1)  then BEGIN 
                            ;comput SS for each contrast
     P = Total(T*M)
     if(n EQ 3) THEN S=1
     P = P^2/Total(T*T)
     P = P/(S*rep)               

    printf,unit,           $
    Format=                $
'(5X,A17,1X,G13.4,3X,I5,3X,G11.4,1x,G11.4, 3X, G11.4)',$
             Name(0),P,1,P,P/MS, 1-F_Test1(P/MS,1,DFE) 

 ENDIF else BEGIN
              R1=ST(2)
              P=Fltarr(R1)
              A=reform(M/S,C)
              if(n EQ 3) THEN S=1
              P = A # T
             T2 = replicate(1.0,C) #  T^2 
             P = S * rep * P^2 / T2
              for i =0L,R1-1 DO BEGIN
                printf,unit,                      $
                Format=     $
                '(5X,A17,1X,G13.4,3X,I5,3X,G11.4,1X,G11.4,3X,G11.4)', $
                           Name(i), P(i),1, P(i),P(i)/MS,    $
                                 1-F_Test1(P(i)/MS,1,DFE)
              ENDFOR
       ENDELSE
 
  RETURN
  END                      ;ContrastH 

                                 
                                 
                                 
                                                                     
                               

 PRO  Anova, X1, FCTEst = FCTEst, FRTest = FRTest,    $
                FRCTest = FRCTest, DFE = DFE, DFC = DFC, $
                 DFR = DFR, DFFRC = DFRC,   $
            One_Way = One, Unequal_One_Way = Unequal,$
             Two_Way = Two, Interactions_Two_Way  = $
            Interactions, Missing=M, List_Name=LN, $
            TContrast=TC, BContrast=BC, IContrast=IC, TName=TN,$
            BName=BN,TCName=TCN, BCName=BCN, ICName=ICN,  $
            No_Printout = NP
;+
;
; NAME:
;	ANOVA
;
; PURPOSE:
;	Perform one-way analysis of variance with
;	equal and unequal sample size, two-way analysis
;	of variance with and without interactions.
;
; CATEGORY:
;	Statistics.
;
; CALLING SEQUENCE:
;	ANOVA, X
;
; INPUTS: 
;	X:	An array of experimental data. For one-way and two-way 
;		analysis of variance without interactions, X must be
;		dimensioned (Treatment#,B),  where B is the maximum
;		sample size (one-way anova) or number of blocks
;		(two-way analysis).  With interactions, X is dimensioned 
;		(Treatment#,I,B), where I is the number of iterates in each
;		cell.
;             
; OUTPUT:
;	Anova table displaying Sum of Squares, Mean Squares,
;	and F Ratio for sources of variation.
;
; KEYWORDS:
;	FCTest = if present and set, returns the value of F for
;		treatment or column variation.
;	FRTest	if present and set, returns value of F for row
;		or block variation.
;	FRCTest	if present and set, returns value of F for column
;		variation.
;	DFE	if present and set, returns denominator degrees of
;		freedom for FCTest,FRTest,FRCTest.
;	DFC	if present and set, returns numerator degrees of
;		for FCTest 
;	DFR	if present and set, returns numerator degrees of for
;		FRTest. 
;	DFRC	if present and set, returns numerator degrees of
;		for FRCTest. 
;
;	Missing	missing data value. If undefined,
;		assume no missing data.If unequal
;		sample sizes, set M to place holding
;		value.
;
;    List_Name:	name of output file. Default is to the
;		screen.
;
;  Type of design structure. Options a
;	ONE_WAY         =  if set, perform 1-way anova.
;	Unequal_ONE_WAY =  if set, perform 1-way ANOVA with
;                             unequal sample sizes.
;	TWO_WAY = if set, perform a 2-way ANOVA.
;	Interactions_TWO_WAY = if set, perform a
;                                2-way ANOVA with
;                                interactions.
;  One and Only one of the options above must be set.
;
;    TContrast:	1- or 2- dimensional array 
;		of treatment contrasts.
;		Each row of TC represents a contrast.
;		TC(i,j) = the coefficient of the mean of
;		the ith treatment in the jth contrast. 
;
;    BContrast:	1- or 2- dimensional array of block
;		contrasts. Each row of BC represents
;		a contrast. BC(i,j) = the coefficient
;		of the mean of the ith block in the jth
;		contrast.                 
;
;    IContrast:	1- or 2- dimensional array of interaction contrasts.  Each 
;		row of TC represents a contrast.  IC(i,j) = the coefficient of
;		the mean of the ith treatment in the jth contrast. 
;
;	TName:	name to be used in the output for treatment type.
;
;	BName:	name to be used in the output for block type.
;	TCName:	vector of names to be used in the output to identify 
;		treatment contrasts.
;	BCName:	vector of names to be used in the output to identify block
;		contrasts.
;	ICName:	vector of names to be used in the output to identify
;		interaction contrasts.
;  No_Printout:	flag, when set, to suppress printing of output.
;
; RESTRICTIONS:
;	NONE.
;
; SIDE EFFECTS:
;	None.
;
; PROCEDURE:
;	Calculation of standard formulas for sum of squares, mean squares and 
;	F ratios.        
;  
;
;-

 On_Error,2
 if N_elements(X1) NE 0 THEN X= double(X1)
 SX=Size(X)        
 C=SX(1)      ; Compute number of columns       
 D= 1         ; Default # of replications
 
 if (N_ELements(LN) EQ 0) THEN  Unit = -1      $
 ELSE openw,unit,/Get,LN

 ONE_WAY = 0 & ONE_WAY_UNEQUAL=1 & TWO_WAY = 2
 TWO_WAY_INTERACTIONS =3

 keyset = [keyword_set(One), keyword_set(Unequal), $
           keyword_set(Two),keyword_set(Interactions)]
  T  = where(keyset,nkey)

 if nkey NE 1 THEN BEGIN
    printf,unit,    $
'anov - must specify one and only one type of design structure'
    goto, DONE
    ENDIF     

 T = T(0)
 if((T EQ TWO_WAY_INTERACTIONS) AND  (SX(0) NE 3)) THEN BEGIN
    printf,unit, 'Anova- wrong number of dimensions' 
    goto,DONE
    ENDIF

 if T NE TWO_WAY_INTERACTIONS THEN  R=SX(2) ELSE BEGIN
   R=SX(3) 
   D=SX(2)    
 ENDELSE
                                       ;Compute number of rows


 if(C LE 1 or R LE 1 ) THEN BEGIN 
   printf,unit,   $
         'ANova- all dimensions must be greater than one' 
   goto,Done
   ENDIF

 if(N_Elements(TN) NE 0) THEN TR=TN ELSE TR='Column'
                                    ;treatment names 

  if(N_Elements(BN) NE 0) THEN Bl=BN else BL='Row'
		          		      ;block names





 if( T EQ ONE_WAY_UNEQUAL and N_Elements(M) ne 0) THEN BEGIN

    
     Pairwise,X,M,YR,Y,notgood,good           ; replace missing data by 0 

     if(R LT  Max(Y)) THEN BEGIN   ; still enough rows ? 
   printf,unit,      $
'Anova Row number of Data array too small for population sizes'  
     goto,DONE
   ENDIF

     if (Min(Y) LE 1) THEN BEGIN
       printf,unit,       $
             ' anova- each sample size must be greater than 1'
       goto,DONE
      ENDIF
     
     N = Total(Y)

 ENDIF ELSE N = R * C *D  



 MEAN = Total(X)/N           ; compute mean

         ;compute total sum of squares
 if T EQ ONE_WAY_UNEQUAL and N_ELEments(Missing) ne 0 THEN $
    SST = Total((X(good) - mean)^2)   $
 else SST= Total((X-mean)^2)    


    ; Pre-process three dimensional array by converting toa
    ; a two - dimensional array whose entries are sums of
    ; repetitions 

 if(T EQ TWO_WAY_INTERACTIONS) THEN BEGIN    
     X= dblarr(C,R)
       
    for i = 0L,R-1 Do for j=0L,C-1 DO          $
     X(j,i) = Total(X1(j,*,i)) 
                     
  ENDIF 

 


 ColTotal=X # replicate(1.,R)   ; compute vector of column totals


 
 DFR= long(R-1)                     ; row degrees of freedom
 DFC= long(C-1)                     ; column degrees of freedom

 case 1 of
              
T EQ ONE_WAY_UNEQUAL OR T EQ ONE_WAY  :       $
      Begin              
            ;compute treatment sum of squares

            if T EQ ONE_WAY_UNEQUAL and N_elements(M) ne 0 THEN      $
               SStr = Total(y*(Coltotal/Y - mean)^2) $
            else SStr = Total(R*(Coltotal/R - mean)^2) 

            SSE = SST - SStr               ;compute error sum of squares
            DFT=N-1                     
            DFE=N-c                        ; error degrees of
                                           ; freedom
            
            MSSE=SSE/DFE                   ; error mean square
            if(MSSE EQ 0) THEN BEGIN
               printf,unit,                $
    'anova- must stop since mean square error =0'
               goto,DONE
            END
            END



T EQ TWO_WAY:Begin 
            RowTotal = replicate(1,C) # X     
                              ;computations for two-way anova
            SSR=  C*Total((RowTotal/C - mean)^2)
            SSTr= R *Total((ColTotal/R - mean)^2)
            SSe=SST-SSTr-SSR
            MSSR=SSR/DFR                      ;row mean square
            DFE=(r-1)*(c-1)
            MSSE=SSE/((r-1)*(c-1))
            if(MSSE EQ 0) THEN BEGIN
            printf,unit,                      $
                 'anova- must stop,since mean square error =0'
            goto,DONE
            END
            FRTest=MSSR/MSSE                 ;F value for rows
            DFT=R*C-1
            END

 T EQ TWO_WAY_INTERACTIONS:BEGIN
            RowTotal = Replicate(1./D,C)#X
                    ;computations for two-way with interactions
            ColTotal = ColTotal/D
            MR = RowTotal/(C)    ; Row means
            MC = ColTotal/(R)    ; Column means
            MI = X/D;              ; Interaction means

            MR1 = Replicate(1.,C) # MR
            MC1 = MC # Replicate(1.,R)

                 ; Treatment sum of squares         
            SSTr= D * R * Total((MC - mean)^2)

                 ; Block sum of squares 
            SSR = D * C * Total((MR - mean)^2)

                ; Interaction sum of squares
           SSRC = D * Total((MI - MR1 - MC1 + mean)^2)
            

            SSE=SST-SSR-SSTR-SSRC
            MSSR=SSR/DFR
            DFRC=(r-1)*(C-1)
            MSSRC=SSRC/DFRC
            DFE=r*c*(D-1)
            MSSE= SSE/DFE
            if(MSSE EQ 0) THEN BEGIN
            printf,unit,        $
                 'anova-must stop,since mean square error =0'
            goto,DONE
            END
            FRTest=MSSR/MSSE
            FRCTest=MSSRC/MSSE
            DFT=r*c*d-1            
            End

            
 


  Else: BEGIN
        printf,unit,     $
    "anova - keyword Structure has unknown value"
        goto,done
        end
 ENDCASE
;
;
      MSSC=SSTr/(c-1) 
                    ; Column mean square for all types of anova
      FCTest=MSSC/MSSE           
                     ;Column F value for all types of anova
  if (N_Elements(NP) EQ 0) THEN BEGIN
    


     
  
      printf,unit,'          Source        SUM OF SQUARES    DF     MEAN SQUARE       F       p'
      printf,unit,'          **************************************************************************'


    if (T EQ TWO_WAY) OR (T EQ TWO_WAY_INTERACTIONS) THEN BEGIN
      printf,unit,       $
       Format=    $
  '(A14,7X,G15.7,3X,I5,3X,G11.4,1X,G11.4,3X,G11.4)',$
                Bl,SSR,DFR,MSSR,FRTEst, 1-F_Test1(FRTEST,DFR,DFE)

      if (N_Elements(BC) NE 0) THEN                 $
         ContrastH,BC,RowTotal,C,MSSe,BCN,2,D,DFE,unit 
    ENDIF

      printf,unit," "
      printf,unit,                                     $

     Format='(A14,7X,G15.7,3X,I5,3X,G11.4,1X,G11.4,3X,G11.4)',$
             Tr,SSTR,DFC,MSSC,FCTEst, 1-F_Test1(FCTEST,DFC,DFE)

    if(N_Elements(TC) NE 0) THEN if(T NE ONE_WAY_UNEQUAL)   $
      THEN ContrastH,TC,ColTOtal,R, MssE,TCN,0,D,DFE,unit
      
       printf,unit," "

 
      if T EQ TWO_WAY_INTERACTIONS THEN BEGIN 
      printf,unit,                    $
      Format=      $
      '(A14,7x,G15.7 ,3x,I5,3x,G11.4,1x,G11.4,3x,G11.4)', $
      'Interaction',SSRC,DFRC,MSSRC,FRCTest,         $
                                   1-F_Test1(FRCTEST,DFRC,DFE)
      if(N_Elements(IC) NE 0) THEN    $
        ContrastH,IC,X,D,MSSe,ICN,3,D, $
                                              DFE,unit
       ENDIF
      printf,unit, " "
      printf,unit,         $
       Format='(A14,7X,G15.7,3X,I5,3X,G11.4)',         $
                               'Error',SSe,DFe,MSSe
      printf,unit, " "
      printf,unit,    $
          Format='(A14,7x,G15.7,3X,I5)', 'Total',SST,DFT
     ENDIF

 DONE:
   if ( unit NE -1) THEN Free_Lun,unit
   Return
 END
            


 
            


 
