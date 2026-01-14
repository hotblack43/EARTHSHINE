
;===============================================================================
;
; MODULE ES_Reflection
;
;
; Version 2012-06-04
;
; Authors: Hans Gleisner & Peter Thejll   (c) Danish Meteorological Institute
;
; References
; ----------
; Hapke, B., JGR, 68, 4571-4586, 1963.
; Hapke, B., Icarus, 157, 523-534, 2002.
; Helfensten, P., et al., Icarus, 128, 2-14, 1997.
; Hillier, J.K, et al., Icarus, 141, 205-225, 1999.
; Kennelly, E.J., et al., Icarus, 210, 14-36, 2010.
;
;===============================================================================




;===============================================================================
;
; Single-particle scattering functions P(g), where g is the phase angle expressed
; in radians.
;
; The functions are normalized to 4*pi when integrated over the sphere, such that
;
;   (1/4*pi) * integral(Pg*dw) = 1
;
; where dw is the solid angle differential.
;
;===============================================================================

FUNCTION Rayleigh, phase_angle
  Pg = (3.0d/4.0d)*(1.0d + cos(phase_angle)^2.0)
  return, Pg
END


FUNCTION Schonberg, phase_angle   ; scattering by a Lambertian particle ??? IS SCALING CORRECT ???
  phase_angle = abs(phase_angle)
  Pg = (8.0d/3.0d) * (sin(phase_angle) + (!dpi-phase_angle)*cos(phase_angle))/!dpi
  return, Pg
END


FUNCTION HenyeyGreenstein, b, phase_angle
  Pg = (1.0d - b^2.0) / ((1.0d - 2.0*b*cos(phase_angle)+b^2.0)^(3.0/2.0))
  return, Pg
END


FUNCTION DoubleHenyeyGreenstein, f, b1, b2, phase_angle
  Pg = (1.0d - f)*HenyeyGreenstein(b1,phase_angle) + f*HenyeyGreenstein(b2,phase_angle)
  ; Pg = ((1.0d + f)/2.0d)*HenyeyGreenstein(b1,phase_angle) + ((1.0d - f)/2.0d)*HenyeyGreenstein(b2,phase_angle)
  return, Pg
END


FUNCTION Legendre1stOrder, a, phase_angle
  Pg = 1.0d + a*cos(phase_angle)
  return, Pg
END


FUNCTION Legendre2ndOrder, a, b, phase_angle
  Pg = 1.0d + a*cos(phase_angle) + b*(3.0*(cos(phase_angle))^2.0 - 1.0d)
  return, Pg
END


FUNCTION DoubleLegendre, a1, b1, a2, b2, phase_angle
  Pg = Legendre2ndOrder(a1,b1,phase_angle) + Legendre2ndOrder(a2,b2,phase_angle)
  return, Pg
END




;===============================================================================
; BiDirectional Reflectance Functions (BRDFs).
;
; NOTE 1: all BRDFs are defined without a cos(inc_angle) factor in the numerator.
;         This factor has to be explicitly applied to the incoming irradiance.
;
; NOTE 2: These are the "true" BRDFs - ratio between outgoing radiance and
;         incoming collimated irradiance. It is important to make a distinction
;         between the BRDF and the function pi*BRDF, referred to in the litterure
;         as "radiance factor", "reflectance factor", or "reflectance function".
;
; The Lambert and the Lommel-Seeliger BRDFs, fL and fLS, are standard.
; The Hapke BRDFs are given by
;
;   fH = fLS * [(1+B0*B)*P*(1+B0c*Bc) + M*(1+Bc)] * S
;
; where
;
;   Pg is the single-particle scattering function,
;   M is the multi-scattering function,
;   B is the shadow-hiding backscattering function,
;   Bc is the coherent backscattering function,
;   S is the surface roughness function.
;
; Hapke63  - The phase function Pg is taken from Hapke [1963].
;            B from Hapke [1963], M=0, Bc=0, S=1
;
; HapkeHG  - Henyey-Greenstein as a phase function Pg.
;            B=0, M=0, Bc=0, S=1
;
; HapkeL2  - 2nd order Legendre polynomial as phase function Pg.
;            B is calculated from Eq (8), M=0, Bc=0, S=1
;
; HapkeDL2 - Double 2nd order Legendre polynomial as phase function Pg.
;            B(g) is calculated from Eq (8), M=0, Bc=0, S=1
;
; PolyfitHillierM - parameters adopted from Table III in Hillier et al. [1999].
; PolyfitHillierH - parameters adopted from Table III in Hillier et al. [1999].
; HapkeHillierM   - parameters adopted from Table V in Hillier et al. [1999].
; HapkeHillierH   - parameters adopted from Table V in Hillier et al. [1999].
;
; HapkeKennellyM1 - parameters adopted from Table 1 in Kennelly et al. [2010].
; HapkeKennellyH1 - parameters adopted from Table 2 in Kennelly et al. [2010].
;===============================================================================

FUNCTION Lambert, ssalbedo, inc_angle, scatt_angle
  mu0 = cos(inc_angle)
  mu  = cos(scatt_angle)
  if (abs(inc_angle) LE !dpi/2.0d) and (abs(scatt_angle) LE !dpi/2.0d) then begin
    BRDF = ssalbedo/!dpi
  endif else begin
    BRDF = 0.0d
  endelse
  return, BRDF
END


FUNCTION LommelSeeliger, ssalbedo, inc_angle, scatt_angle
  mu0 = cos(inc_angle)
  mu  = cos(scatt_angle)
  Pg  = 1.0d0
  Bg  = 0.0d0
  M   = 0.0d0
  S   = 1.0d0
  if (inc_angle LE !dpi/2.0d) and (scatt_angle LE !dpi/2.0d) then begin
    BRDF = (ssalbedo/(4.0d*!dpi)) * (1.0d/(mu0+mu)) * Pg
  endif else begin
    BRDF = 0.0d
  endelse
  return, BRDF
END


FUNCTION Hapke63, ssalbedo, inc_angle, scatt_angle, phase_angle
  ; Note: All angles are assumed to be radians
  w0  = ssalbedo
  mu0 = cos(inc_angle)
  mu  = cos(scatt_angle)
  t   = 0.1d
  Pg  = Schonberg(abs(phase_angle)) + (8.0d/3.0d) * (t*(1.0d - cos(abs(phase_angle)))^2)
  g   = 0.6d
  if (phase_angle EQ 0.0d) then begin
    Bg = 1.0d
  endif else if ((phase_angle GT 0.0d) AND (phase_angle LT (!dpi/2.0d - 0.00001d))) then begin
    Bg = 1.0d - (tan(phase_angle)/(2.0d*g)) * (1.0d - exp(-g/tan(phase_angle))) * (3.0d - exp(-g/tan(phase_angle)))
  endif else if (phase_angle GE (!dpi/2.0d - 0.00001d)) then begin
    Bg = 0.0d
  endif else begin
    stop, 'ERROR in function Hapke63: invalid phase angle.'
  endelse
  M = 0.0d0
  S = 1.0d0
  if (inc_angle LE !dpi/2.0d) and (scatt_angle LE !dpi/2.0d) then begin
    BRDF = (w0/(4.0d*!dpi)) * (1.0d/(mu0+mu)) * (1.0d + Bg)*Pg
  endif else begin
    BRDF = 0.0d
  endelse
  return, BRDF
END


FUNCTION HapkeX, inc_angle, scatt_angle, phase_angle, ssalbedo=ssalbedo, factor=factor

  w0 = 0.2379
  if (keyword_set(ssalbedo)) then begin
    w0 = ssalbedo
  endif else if (keyword_set(factor)) then begin
    w0 = factor*w0
  endif else begin
    w0 = w0
  endelse
  c   = 0.45    ; Henyey-Greenstein parameter
  g1  = -0.30   ;           -||-
  g2  = 0.65    ;           -||-
  B0  = 1.00    ; Back-scattering (shadow-hiding)
  h   = 0.05    ;           -||-
  B0c = 0.50    ; Back-scattering (coherent)
  hc  = 0.10    ;           -||-

  mu0  = cos(inc_angle)
  mu   = cos(scatt_angle)
  Pg   = DoubleHenyeyGreenstein(c, -1.0*g1, -1.0*g2, abs(phase_angle))
  Bg   = B0/(1.0d + (1.0d/h)*tan(abs(phase_angle)/2.0d))
  ; Hmu0 = (1.0d0 + 2.0d*mu0)/(1.0d + 2.0d*mu0*sqrt(1.0d - w0))
  ; Hmu  = (1.0d0 + 2.0d*mu)/(1.0d  + 2.0d*mu*sqrt(1.0d - w0))
  ; M    = Hmu0*Hmu - (1.0d - 3.0d*((1.0-c)*(-g1)+c*(-g2))*cos(phase_angle))
  M = 0.0d

  ;--- coherent backscatter
  if (phase_angle GT 0.0d) then begin
    Bc = (1.0d + (1.0d - exp(-1.0*(1.0d/hc)*tan(phase_angle/2.0d)))/((1.0d/hc)*tan(phase_angle/2.0d))) / (2.0*(1.0d + (1.0d/hc)*tan(phase_angle/2.0d))^2)
  endif else if (phase_angle EQ 0.0d) then begin
    Bc = 1.0d
  endif else begin
    stop, 'ERROR (HapkeX): phase angle out of range [0.0,180.0].'
  endelse
  Bc = 0.0d

  ;--- surface roughness
  S = 1.0d

  if (inc_angle LE !dpi/2.0d) and (scatt_angle LE !dpi/2.0d) then begin
    BRDF = (w0/(4.0d*!dpi)) * (1.0d/(mu0+mu)) * ((1.0d + Bg)*Pg + M) * (1.0d + B0c*Bc) * S
  endif else begin
    BRDF = 0.0d
  endelse
  return, BRDF
END


FUNCTION HapkeHG, ssalbedo, inc_angle, scatt_angle, phase_angle, b
  w0  = ssalbedo
  mu0 = cos(inc_angle)
  mu  = cos(scatt_angle)
  Pg  = HenyeyGreenstein(b,phase_angle)
  Bg  = 0.0d0
  M   = 0.0d0
  S   = 1.0d0
  if (inc_angle GE !DPI/2.0d) OR (scatt_angle GT !DPI/2.0d) then return,0.0d
  BRDF = (w0/4.0d0/!DPI) * (1.0d0/(mu0+mu)) * (1.0d + Bg)*Pg
  return, BRDF
END


FUNCTION HapkeL2, ssalbedo, inc_angle, scatt_angle, phase_angle, B0, h, a, b
  w0  = ssalbedo
  mu0 = cos(inc_angle)
  mu  = cos(scatt_angle)
  Pg  = Legendre2ndOrder(a,b,phase_angle)
  Bg  = B0/(1.0d + (1.0d/h)*tan(phase_angle/2.0d))
  M   = 0.0d0
  S   = 1.0d0
  if (inc_angle GE !DPI/2.0d) OR (scatt_angle GT !DPI/2.0d) then return,0.0d
  BRDF = (w0/4.0d0/!DPI) * (1.0d0/(mu0+mu)) * (1.0d + Bg)*Pg
  return, BRDF
END


FUNCTION HapkeDL2, ssalbedo, inc_angle, scatt_angle, phase_angle, B0, h, a1, b1, a2, b2
  w0  = ssalbedo
  mu0 = cos(inc_angle)
  mu  = cos(scatt_angle)
  Pg  = DoubleLegendre(a1,b1,a2,b2,phase_angle)
  Bg  = B0/(1.0d + (1.0d/h)*tan(phase_angle/2.0d))
  M   = 0.0d0
  S   = 1.0d0
  if (inc_angle GE !DPI/2.0d) OR (scatt_angle GT !DPI/2.0d) then return,0.0d
  BRDF = (w0/4.0d0/!DPI) * (1.0d0/(mu0+mu)) * (1.0d + Bg)*Pg
  return, BRDF
END


FUNCTION PolyfitHillierM, color, inc_angle, scatt_angle, phase_angle
  color = fix(color)
  if (color LT 1 OR color GT 5) then stop, 'ERROR in PolyfitHillierM: invalid color'

  b0 = [-0.0198, -0.0661, -0.0633, -0.0558, -0.0486]
  b1 = [ 0.600,   0.359,   0.356,   0.373,   0.320]
  a0 = [ 0.226,   0.362,   0.366,   0.358,   0.328]
  a1 = [-11.08,  -20.01,  -19.76,  -18.73,  -15.23]*1.0e-3
  a2 = [ 30.82,   61.78,   60.27,   55.84,   44.10]*1.0e-5
  a3 = [-39.25,  -81.46,  -78.78,  -71.52,  -56.31]*1.0e-7
  a4 = [ 17.89,   37.16,   35.63,   31.61,   24.76]*1.0e-9

  b0 = b0[color-1]
  b1 = b1[color-1]
  a0 = a0[color-1]
  a1 = a1[color-1]
  a2 = a2[color-1]
  a3 = a3[color-1]
  a4 = a4[color-1]

  mu0 = cos(inc_angle)
  mu  = cos(scatt_angle)
  phi = phase_angle * (180.0d/!dpi)  ; convert radians to degrees for use in the polynomial

  if (inc_angle LE !dpi/2.0d) and (scatt_angle LE !dpi/2.0d) then begin
    BRDF = (1.0d/(mu0+mu)) * (1.0/!dpi)*(b0*exp(-b1*phi) + a0 + a1*phi + a2*phi^2 + a3*phi^3 + a4*phi^4)
  endif else begin
    BRDF = 0.0d
  endelse
  return, BRDF
END


FUNCTION PolyfitHillierH, color, inc_angle, scatt_angle, phase_angle
  color = fix(color)
  if (color LT 1 OR color GT 5) then stop, 'ERROR in PolyfitHillierH: invalid color'

  b0 = [ 0.1053,  0.1718,  0.1598,  0.1589,  0.3545]
  b1 = [ 0.541,   0.374,   0.450,   0.498,   0.194]
  a0 = [ 0.316,   0.414,   0.451,   0.461,   0.193]
  a1 = [-9.65 ,  -4.48,   -6.72,   -7.50,   19.80]*1.0e-3
  a2 = [ 23.57,  -7.42,    3.81,    7.44,  -89.65]*1.0e-5
  a3 = [-37.46,   18.75,  -3.47,   -9.37,  136.01]*1.0e-7
  a4 = [ 24.18,  -9.26,    5.36,    8.42,  -69.15]*1.0e-9

  b0 = b0[color-1]
  b1 = b1[color-1]
  a0 = a0[color-1]
  a1 = a1[color-1]
  a2 = a2[color-1]
  a3 = a3[color-1]
  a4 = a4[color-1]

  mu0 = cos(inc_angle)
  mu  = cos(scatt_angle)
  phi = phase_angle * (180.0d/!dpi)  ; convert to degrees for use in the polynomial below.

  if (inc_angle LE !dpi/2.0d) and (scatt_angle LE !dpi/2.0d) then begin
    BRDF = (1.0d/(mu0+mu)) * (1.0/!dpi)*(b0*exp(-b1*phi) + a0 + a1*phi + a2*phi^2 + a3*phi^3 + a4*phi^4)
  endif else begin
    BRDF = 0.0d
  endelse
  return, BRDF
END


FUNCTION HapkeHillierM, color, inc_angle, scatt_angle, phase_angle, ssalbedo=ssalbedo, factor=factor
  color = fix(color)
  if (color LT 1 OR color GT 5) then stop, 'ERROR in HapkeHillierM: invalid color'

  w0  = [ 0.203,  0.333,  0.343,  0.339,  0.334]
  g1  = [-0.307, -0.226, -0.233, -0.231, -0.266]
  B0  = [ 1.00,   1.00,   1.00,   1.00,   0.99]
  h   = [ 0.042,  0.068,  0.061,  0.067,  0.060]
  B0c = [ 1.00,   1.00,   1.00,   1.00,   0.57]
  hc  = [ 0.1425, 0.2075, 0.1825, 0.2000, 0.1875]  ; obtained from Kennelly et al. [2010] as Da/40

  if (keyword_set(ssalbedo)) then begin
    w0 = ssalbedo
  endif else if (keyword_set(factor)) then begin
    w0 = factor*w0[color-1]
  endif else begin
    w0 = w0[color-1]
  endelse
  c     = 0.45          ; Henyey-Greenstein parameter
  g1    = g1[color-1]   ;           -||-
  g2    = 0.65          ;           -||-
  B0    = B0[color-1]   ; Back-scattering (shadow-hiding)
  h     = h[color-1]    ;           -||-
  B0c   = B0c[color-1]  ; Back-scattering (coherent)
  hc    = hc[color-1]   ;           -||-

  mu0  = cos(inc_angle)
  mu   = cos(scatt_angle)
  Pg   = DoubleHenyeyGreenstein(c, -1.0*g1, -1.0*g2, phase_angle)
  Bg   = B0/(1.0d + (1.0d/h)*tan(phase_angle/2.0d))
  Hmu0 = (1.0d0 + 2.0d*mu0)/(1.0d + 2.0d*mu0*sqrt(1.0d - w0))
  Hmu  = (1.0d0 + 2.0d*mu)/(1.0d  + 2.0d*mu*sqrt(1.0d - w0))
  M    = Hmu0*Hmu - (1.0d - 3.0d*((1.0-c)*(-g1)+c*(-g2))*cos(phase_angle))

  ;--- coherent backscatter (using Bc from Hapke [2002] scaled with 0.54)
  if (phase_angle GT 0.0d) then begin
    Bc = 0.54d * (1.0d + (1.0d - exp(-1.0*(1.0d/hc)*tan(phase_angle/2.0d)))/((1.0d/hc)*tan(phase_angle/2.0d))) / (2.0*(1.0d + (1.0d/hc)*tan(phase_angle/2.0d))^2)
  endif else if (phase_angle EQ 0.0d) then begin
    Bc = 0.54d * 1.0d
  endif else begin
    stop, 'ERROR (HapkeHillierM): phase angle out of range [0.0,180.0].'
  endelse

  ;--- surface roughness
  if (sin(inc_angle)*sin(scatt_angle) EQ 0.0d) then begin
    cospsi = 1.0d
  endif else begin
    cospsi = double( (cos(phase_angle) - mu0*mu)/(sin(inc_angle)*sin(scatt_angle)) )
  endelse
  if ((cospsi GT -1.0d) AND (cospsi LT 1.0d)) then begin
    psi = acos(cospsi)
    f   = exp(-2*tan(psi/2.0d))
  endif else if (cospsi LE -1.0d) then begin
    psi = acos(-1.0d)
    f   = exp(-2*tan(psi/2.0d))
  endif else if (cospsi GE 1.0d) then begin
    psi = acos(1.0d)
    f   = 0.0d
  endif else begin
    stop, 'ERROR (HapkeHillierM): cos(psi) out of range [-1.0,+1.0]: ', inc_angle*180.0/!pi, scatt_angle*180.0/!pi, phase_angle*180.0/!pi, arccos
  endelse
  Sg = (1.0/sqrt(1.0+tan(27.0d*!dpi/180.0d)^2)) * (1.0/(1.0 - f + f/(sqrt(1.0+tan(27.0d*!dpi/180.0d)^2))))

  if (inc_angle LE !dpi/2.0d) and (scatt_angle LE !dpi/2.0d) then begin
    BRDF = (w0/(4.0d*!dpi)) * (1.0d/(mu0+mu)) * ( (1.0d + Bg)*Pg*(1.0d + B0c*Bc) + M*(1.0d + Bc) ) * Sg
  endif else begin
    BRDF = 0.0d
  endelse
  return, BRDF
END


FUNCTION HapkeHillierH, color, inc_angle, scatt_angle, phase_angle, ssalbedo=ssalbedo, factor=factor
  color = fix(color)
  if (color LT 1 OR color GT 5) then stop, 'ERROR in HapkeHillierH: invalid color'

  w0  = [ 0.354,  0.512,  0.552,  0.565,  0.577]
  g1  = [-0.325, -0.338, -0.320, -0.311, -0.312]
  B0  = [ 1.00,   1.00,   1.00,   0.84,   0.32]
  h   = [ 0.047,  0.055,  0.060,  0.063,  0.128]
  B0c = [ 0.41,   0.11,   0.06,   0.14,   1.00]
  hc  = [ 0.1500, 0.0275, 0.0175, 0.0775, 0.0225]  ; obtained from Kennelly et al. [2010] as Da/40

  if (keyword_set(ssalbedo)) then begin
    w0 = ssalbedo
  endif else if (keyword_set(factor)) then begin
    w0 = factor*w0[color-1]
  endif else begin
    w0 = w0[color-1]
  endelse
  c     = 0.45          ; Henyey-Greenstein parameter
  g1    = g1[color-1]   ;           -||-
  g2    = 0.65          ;           -||-
  B0    = B0[color-1]   ; Back-scattering (shadow-hiding)
  h     = h[color-1]    ;           -||-
  B0c   = B0c[color-1]  ; Back-scattering (coherent)
  hc    = hc[color-1]   ;           -||-

  mu0  = cos(inc_angle)
  mu   = cos(scatt_angle)
  Pg   = DoubleHenyeyGreenstein(c, -1.0*g1, -1.0*g2, phase_angle)
  Bg   = B0/(1.0d + (1.0d/h)*tan(phase_angle/2.0d))
  Hmu0 = (1.0d0 + 2.0d*mu0)/(1.0d + 2.0d*mu0*sqrt(1.0d - w0))
  Hmu  = (1.0d0 + 2.0d*mu)/(1.0d  + 2.0d*mu*sqrt(1.0d - w0))
  M    = Hmu0*Hmu - (1.0d - 3.0d*((1.0-c)*(-g1)+c*(-g2))*cos(phase_angle))

  ;--- coherent backscatter (using Bc from Hapke [2002] scaled with 0.54)
  if (phase_angle GT 0.0d) then begin
    Bc = 0.54d * (1.0d + (1.0d - exp(-1.0*(1.0d/hc)*tan(phase_angle/2.0d)))/((1.0d/hc)*tan(phase_angle/2.0d))) / (2.0*(1.0d + (1.0d/hc)*tan(phase_angle/2.0d))^2)
  endif else if (phase_angle EQ 0.0d) then begin
    Bc = 0.54d * 1.0d
  endif else begin
    stop, 'ERROR (HapkeHillierH): phase angle out of range [0.0,180.0].'
  endelse

  ;--- surface roughness
  if (sin(inc_angle)*sin(scatt_angle) EQ 0.0d) then begin
    cospsi = 1.0d
  endif else begin
    cospsi = double( (cos(phase_angle) - mu0*mu)/(sin(inc_angle)*sin(scatt_angle)) )
  endelse
  if ((cospsi GT -1.0d) AND (cospsi LT 1.0d)) then begin
    psi = acos(cospsi)
    f   = exp(-2*tan(psi/2.0d))
  endif else if (cospsi LE -1.0d) then begin
    psi = acos(-1.0d)
    f   = exp(-2*tan(psi/2.0d))
  endif else if (cospsi GE 1.0d) then begin
    psi = acos(1.0d)
    f   = 0.0d
  endif else begin
    stop, 'ERROR (HapkeHillierH): cos(psi) out of range [-1.0,+1.0]: ', inc_angle*180.0/!pi, scatt_angle*180.0/!pi, phase_angle*180.0/!pi, arccos
  endelse
  Sg = (1.0/sqrt(1.0+tan(27.0d*!dpi/180.0d)^2)) * (1.0/(1.0 - f + f/(sqrt(1.0+tan(27.0d*!dpi/180.0d)^2))))

  if (inc_angle LE !dpi/2.0d) and (scatt_angle LE !dpi/2.0d) then begin
    BRDF = (w0/(4.0d*!dpi)) * (1.0d/(mu0+mu)) * ( (1.0d + Bg)*Pg*(1.0d + B0c*Bc) + M*(1.0d + Bc)) * Sg
  endif else begin
    BRDF = 0.0d
  endelse
  return, BRDF
END


FUNCTION HapkeKennellyM1, color, inc_angle, scatt_angle, phase_angle, ssalbedo=ssalbedo, factor=factor
  color = fix(color)
  if (color LT 1 OR color GT 5) then stop, 'ERROR in HapkeKennellyM1: invalid color'

  w0  = [ 0.193,  0.326,  0.334,  0.331,  0.320]
  g1  = [-0.281, -0.211, -0.218, -0.216, -0.241]
  B0  = [ 1.00,   1.00,   0.95,   1.00,   1.00]
  h   = [ 0.15,   0.15,   0.15,   0.15,   0.15]
  B0c = [ 0.75,   0.60,   0.65,   0.60,   0.45]
  hc  = [0.075,   0.120,  0.105,  0.120,  0.105]

  if (keyword_set(ssalbedo)) then begin
    w0 = ssalbedo
  endif else if (keyword_set(factor)) then begin
    w0 = factor*w0[color-1]
  endif else begin
    w0 = w0[color-1]
  endelse
  c     = 0.45
  g2    = 0.65
  g1    = g1[color-1]
  B0    = B0[color-1]
  h     = h[color-1]
  B0c   = B0c[color-1]
  hc    = hc[color-1]

  mu0  = cos(inc_angle)
  mu   = cos(scatt_angle)
  Pg   = DoubleHenyeyGreenstein(c, -1.0*g1, -1.0*g2, phase_angle)
  Bg   = B0/(1.0d + (1.0d/h)*tan(phase_angle/2.0d))
  Hmu0 = (1.0d0 + 2.0d*mu0)/(1.0d + 2.0d*mu0*sqrt(1.0d - w0))
  Hmu  = (1.0d0 + 2.0d*mu)/(1.0d  + 2.0d*mu*sqrt(1.0d - w0))
  M    = Hmu0*Hmu - (1.0d - 3.0d*((1.0-c)*(-g1)+c*(-g2))*cos(phase_angle))

  ;--- coherent backscatter
  if (phase_angle GT 0.0d) then begin
    Bc = (1.0d + (1.0d - exp(-1.0*(1.0d/hc)*tan(phase_angle/2.0d)))/((1.0d/hc)*tan(phase_angle/2.0d))) / (2.0*(1.0d + (1.0d/hc)*tan(phase_angle/2.0d))^2)
  endif else if (phase_angle EQ 0.0d) then begin
    Bc = 1.0d
  endif else begin
    stop, 'ERROR (HapkeKennellyM1): phase angle out of range [0.0,180.0].'
  endelse

  ;--- surface roughness
  if (sin(inc_angle)*sin(scatt_angle) EQ 0.0d) then begin
    cospsi = 1.0d
  endif else begin
    cospsi = double( (cos(phase_angle) - mu0*mu)/(sin(inc_angle)*sin(scatt_angle)) )
  endelse
  if ((cospsi GT -1.0d) AND (cospsi LT 1.0d)) then begin
    psi = acos(cospsi)
    f   = exp(-2*tan(psi/2.0d))
  endif else if (cospsi LE -1.0d) then begin
    psi = acos(-1.0d)
    f   = exp(-2*tan(psi/2.0d))
  endif else if (cospsi GE 1.0d) then begin
    psi = acos(1.0d)
    f   = 0.0d
  endif else begin
    stop, 'ERROR (HapkeKennellyM1): cos(psi) out of range [-1.0,+1.0]: ', inc_angle*180.0/!pi, scatt_angle*180.0/!pi, phase_angle*180.0/!pi, arccos
  endelse
  Sg = (1.0/sqrt(1.0+tan(27.0d*!dpi/180.0d)^2)) * (1.0/(1.0 - f + f/(sqrt(1.0+tan(27.0d*!dpi/180.0d)^2))))

  if (inc_angle LE !dpi/2.0d) and (scatt_angle LE !dpi/2.0d) then begin
    BRDF = (w0/(4.0d*!dpi)) * (1.0d/(mu0+mu)) * ((1.0d + Bg)*Pg + M) * (1.0d + B0c*Bc) * Sg
  endif else begin
    BRDF = 0.0d
  endelse
  return, BRDF
END


FUNCTION HapkeKennellyH1, color, inc_angle, scatt_angle, phase_angle, ssalbedo=ssalbedo, factor=factor
  color = fix(color)
  if (color LT 1 OR color GT 5) then stop, 'ERROR in HapkeKennellyH1: invalid color'

  w0  = [ 0.328,  0.480,  0.518,  0.525,  0.549]
  g1  = [-0.307, -0.324, -0.309, -0.289, -0.307]
  B0  = [ 0.95,   0.80,   0.80,   0.95,   0.50]
  h   = [ 0.15,   0.15,   0.15,   0.15,   0.15]
  B0c = [ 0.45,   0.35,   0.30,   0.25,   0.45]
  hc  = [ 0.075,  0.060,  0.060,  0.060,  0.030]

  if (keyword_set(ssalbedo)) then begin
    w0 = ssalbedo
  endif else if (keyword_set(factor)) then begin
    w0 = factor*w0[color-1]
  endif else begin
    w0 = w0[color-1]
  endelse
  c     = 0.45
  g2    = 0.65
  g1    = g1[color-1]
  B0    = B0[color-1]
  h     = h[color-1]
  B0c   = B0c[color-1]
  hc    = hc[color-1]

  mu0  = cos(inc_angle)
  mu   = cos(scatt_angle)
  Pg   = DoubleHenyeyGreenstein(c, -1.0*g1, -1.0*g2, phase_angle)
  Bg   = B0/(1.0d + (1.0d/h)*tan(phase_angle/2.0d))
  Hmu0 = (1.0d0 + 2.0d*mu0)/(1.0d + 2.0d*mu0*sqrt(1.0d - w0))
  Hmu  = (1.0d0 + 2.0d*mu)/(1.0d  + 2.0d*mu*sqrt(1.0d - w0))
  M    = Hmu0*Hmu - (1.0d - 3.0d*((1.0-c)*(-g1)+c*(-g2))*cos(phase_angle))

  ;--- coherent backscatter
  if (phase_angle GT 0.0d) then begin
    Bc = (1.0d + (1.0d - exp(-1.0*(1.0d/hc)*tan(phase_angle/2.0d)))/((1.0d/hc)*tan(phase_angle/2.0d))) / (2.0*(1.0d + (1.0d/hc)*tan(phase_angle/2.0d))^2)
  endif else if (phase_angle EQ 0.0d) then begin
    Bc = 1.0d
  endif else begin
    stop, 'ERROR (HapkeKennellyH1): phase angle out of range [0.0,180.0].'
  endelse

  ;--- surface roughness
  if (sin(inc_angle)*sin(scatt_angle) EQ 0.0d) then begin
    cospsi = 1.0d
  endif else begin
    cospsi = double( (cos(phase_angle) - mu0*mu)/(sin(inc_angle)*sin(scatt_angle)) )
  endelse
  if ((cospsi GT -1.0d) AND (cospsi LT 1.0d)) then begin
    psi = acos(cospsi)
    f   = exp(-2*tan(psi/2.0d))
  endif else if (cospsi LE -1.0d) then begin
    psi = acos(-1.0d)
    f   = exp(-2*tan(psi/2.0d))
  endif else if (cospsi GE 1.0d) then begin
    psi = acos(1.0d)
    f   = 0.0d
  endif else begin
    stop, 'ERROR (HapkeKennellyM1): cos(psi) out of range [-1.0,+1.0]: ', inc_angle*180.0/!pi, scatt_angle*180.0/!pi, phase_angle*180.0/!pi, arccos
  endelse
  Sg = (1.0/sqrt(1.0+tan(27.0d*!dpi/180.0d)^2)) * (1.0/(1.0 - f + f/(sqrt(1.0+tan(27.0d*!dpi/180.0d)^2))))

  if (inc_angle LE !dpi/2.0d) and (scatt_angle LE !dpi/2.0d) then begin
    BRDF = (w0/(4.0d*!dpi)) * (1.0d/(mu0+mu)) * ((1.0d + Bg)*Pg + M) * (1.0d + B0c*Bc) * Sg
  endif else begin
    BRDF = 0.0d
  endelse
  return, BRDF
END




;===============================================================================
; Mixed BRDFs.
;
; Hapke63_Lambert: mix of Hapke63 and Lambert.
;===============================================================================

FUNCTION Hapke63_Lambert, ssalbedo, inc_angle, scatt_angle, phase_angle, mixingratio
  BRDF_Hapke63 = Hapke63(ssalbedo, inc_angle, scatt_angle, phase_angle)
  BRDF_Lambert = Lambert(ssalbedo, inc_angle, scatt_angle)
  BRDF         = mixingratio*BRDF_Hapke63 + (1.0d - mixingratio)*BRDF_Lambert
  return, BRDF
END




PRO ES_Reflection
END
