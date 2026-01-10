
FUNCTION _sin1, x, p, nx, np
  p0 = transpose(rebin(reform(p[0, *]), np, nx))
  f = sin(2*!pi*x/p0)+2
  return, f
END 

FUNCTION _sin1_chi2, p, np, funa = funa
  nx = n_elements(funa.x)
  xx = rebin(funa.x, nx, np)
  yy = rebin(funa.y, nx, np)
  ee = rebin(funa.e, nx, np)
  f = _sin1(xx, p, nx, np)
  chi = total((yy-f)^2/ee^2, 1)
  return, chi
END 

col0 = 180
th = 5
prange = [2e-2, 1]

; DATA
nx = 15
p = [0.333]
ndim = n_elements(p)
x = randomu(seed, nx)
y = _sin1(x, p, nx, ndim)
e = 1.*sqrt(abs(y))*randomn(seed, nx)
y = y+e
e = abs(e)

; MODEL
nm = 1000
xm = findgen(nm)/nm
ym = _sin1(xm, p, nm, 1)

; CHI2
np = 1e+3
ps = reform(findgen(np)/np, 1, np)
funa = {x:x, y:y, e:e}
chi2 = _sin1_chi2(ps, np, funa = funa)

; PERIODOGRAM
lnp = lnp_test(x, y, wk1 = freq, wk2 = amp, ofac = 16, hifac = 32)

; SOLBER
sol = solber('_sin1_chi2', ndim, funa = funa, npop = 100, plot_flag = 2, ngen_max = 10, term_fit = 1, status = status, ngen_tot = ngen_tot, gfit_best = gfit_best, save_gen = save_gen, save_gfit = save_gfit)
snapshot = TVRD(True = 1)
write_png, 'solber_stat.png', snapshot


; PLOT
window, 1, retain = 2, xs = 300, ys = 600
device, decomposed = 0
!p.multi = [0, 1, 4]
!y.margin = [3, 2]
!p.charsize = 1.6
; usym
a = findgen(17) * (!PI*2/16.)  
usersym, cos(a), sin(a), /FILL   
; plot data
plot, [0], [0], background = 255, color = 0, xr = [0, 1], yr = minmax([y-e, y+e]), title = 'Model+Data'
oplot, xm, ym, color = col0, thick = th
oplot, x, y, psym = 8, color = 0
errplot, x, y-e, y+e, color = 0

; plot chi2
yr_chi = [0.7*min(chi2, /nan), 1.2*max(chi2, /nan)]
plot, [0], [0], xr = prange, xs = 1, yr = yr_chi, ys = 1, /ylog, color = 0, title = 'Chi2 vs period'
FOR i = 0D, n_elements(save_gfit)-1 DO oplot, save_gen[i]*[1, 1], [yr_chi[0], save_gfit[i]], color = col0
oplot, ps, chi2, color = 0
arrow, p[0], yr_chi[1], p[0], yr_chi[1]-0.5*(yr_chi[1]-yr_chi[0]), color = 0, /data


; plot periodogram
yr = [0, 1.1*max(amp)]
plot, [0], [0], xr = prange, xs = 1, color = 0, yr = yr, ys = 1, title = 'Periodogram'
oplot, p[0]*[1, 1], yr, color = col0, thick = th
oplot, 1./freq, amp, color = 0

; plot solber solution
oplot, sol[0]*[1, 1], yr, color =0

; compare solutions
plot, [0], [0], background = 255, color = 0, xr = [0, 1], yr = minmax([y-e, y+e]), title = 'Model+Data vs Solber'
oplot, xm, ym, color = col0, thick = 5
oplot, x, y, psym = 8, color = 0
errplot, x, y-e, y+e, color = 0
ysol = _sin1(xm, sol, nm, 1)
oplot, xm, ysol, color = 0

!p.multi = 0

snapshot = TVRD(True = 1)
write_png, 'solber_sin1.png', snapshot


END 
