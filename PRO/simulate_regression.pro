Return-Path: <pth@dmi.dk>
Received: from fep26.mail.dk ([130.226.71.185]) by fep34.mail.dk
          (InterMail vM.7.05.02.00 201-2174-114-20060621) with ESMTP
          id <20061010122511.IPWV24188.fep34.mail.dk@fep26.mail.dk>
          for <thejll@mail.dk>; Tue, 10 Oct 2006 14:25:11 +0200
Received: from mailgw.dmi.dk ([130.226.71.185]) by fep26.mail.dk
          (InterMail vG.2.02.00.00 201-2161-120-101-20051020) with ESMTP
          id <20061010122511.MZQG16912.fep26.mail.dk@mailgw.dmi.dk>
          for <thejll@mail.dk>; Tue, 10 Oct 2006 14:25:11 +0200
Received: from localhost (localhost.dmi.dk [127.0.0.1])
	by mailgw.dmi.dk (8.12.3/8.12.11/Debian-1) with ESMTP id k9ACP9Tn027239
	for <thejll@mail.dk>; Tue, 10 Oct 2006 12:25:09 GMT
Received: from mailgw.dmi.dk ([127.0.0.1])
	by localhost (mailgw.dmi.dk [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 26961-06 for <thejll@mail.dk>;
	Tue, 10 Oct 2006 12:25:08 +0000 (GMT)
Received: from postoffice.dmi.dk (postoffice.dmi.dk [130.226.64.60])
	by mailgw.dmi.dk (8.12.3/8.12.11/Debian-1) with ESMTP id k9ACP7Gg027221
	for <thejll@mail.dk>; Tue, 10 Oct 2006 12:25:07 GMT
Received: from localhost (localhost.dmi.dk [127.0.0.1])
	by postoffice.dmi.dk (Postfix) with ESMTP id 0B7BD181A3
	for <thejll@mail.dk>; Tue, 10 Oct 2006 12:25:07 +0000 (GMT)
Received: from postoffice.dmi.dk ([127.0.0.1])
	by localhost (postoffice.dmi.dk [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 21043-01-53 for <thejll@mail.dk>;
	Tue, 10 Oct 2006 12:25:06 +0000 (GMT)
Received: from egregious.dmi.dk (egregious [130.226.67.115])
	by postoffice.dmi.dk (Postfix) with ESMTP id E87711819D
	for <thejll@mail.dk>; Tue, 10 Oct 2006 12:25:06 +0000 (GMT)
Received: from pth by egregious.dmi.dk with local (Exim 3.36 #1 (Debian))
	id 1GXGfS-00018H-00
	for <thejll@mail.dk>; Tue, 10 Oct 2006 14:25:06 +0200
To: thejll@mail.dk
Message-Id: <E1GXGfS-00018H-00@egregious.dmi.dk>
From: Peter Thejll <pth@dmi.dk>
Date: Tue, 10 Oct 2006 14:25:06 +0200
X-Virus-Scanned: by amavisd-new-20030616-p10 (Debian) at dmi.dk
X-Virus-Scanned: by amavisd-maia-1.0.0-rc5 (Debian) at dmi.dk
X-NAS-Classification: 0
X-NAS-MessageID: 81
X-NAS-Validation: {3B152552-4344-42AD-A9D1-2C4D230220A7}

!P.MULTI=[0,1,2]
nsims=1000
npoints=100
nvars=5
coefs=findgen(nvars)
const=23.0
slope=0.03
x=fltarr(nvars,npoints)
keep=911.911
keep_val=911.911
keep_co=911.911
keep_val_co=911.911
for isim=0,nsims-1,1 do begin
	for ivar=0,nvars-1,1 do x(ivar,*)=randomn(seed,npoints)+slope*findgen(npoints)
	noise=randomn(seed,npoints)
	y=reform(const+coefs#x+noise)
; regress on one subset..
	kdx=indgen(npoints)
	kdx=kdx(where (kdx le 45 or kdx ge 55))
	res=regress(x(*,kdx),y(kdx),/double,yfit=yfit,const=const)
	residual=y(kdx)-yfit
	keep=[keep,residual]
	plot,residual,ytitle='Residual'
; validate on midpoint of window
	y_recon_midpoint=const+res#x(*,npoints/2)
	y_val_res=y(npoints/2)-y_recon_midpoint
	keep_val=[keep_val,y_val_res]
; now repeat with CO
; regress on one subset..
	res=co_regress(x(*,kdx),y(kdx),/double,yfit=yfit,const=const)
	residual_co=y(kdx)-yfit
	keep_co=[keep_co,residual_co]
	plot,residual_co,ytitle='Residual CO'
; validate on midpoint of window
	y_recon_midpoint=const+res#x(*,npoints/2)
	y_val_res_co=y(npoints/2)-y_recon_midpoint
	keep_val_co=[keep_val_co,y_val_res_co]
endfor	; end of isim loop
idx=where(keep ne 911.911)
combined_residuals=keep(idx)
idx=where(keep_val ne 911.911)
combined_keep_val=keep_val(idx)
print,'Statistics of OLS residuals:'
print,'mean	:',mean(combined_residuals)
print,'STD	:',stddev(combined_residuals)
print,'Statistics of OLS validation residuals:'
print,'mean	:',mean(combined_keep_val)
print,'STD	:',stddev(combined_keep_val)
print,"            "
idx=where(keep ne 911.911)
combined_residuals_co=keep_co(idx)
idx=where(keep_val_co ne 911.911)
combined_keep_val_co=keep_val_co(idx)
print,'Statistics of CO residuals:'
print,'mean	:',mean(combined_residuals_co)
print,'STD	:',stddev(combined_residuals_co)
print,'Statistics of CO validation residuals:'
print,'mean	:',mean(combined_keep_val_co)
print,'STD	:',stddev(combined_keep_val_co)
end
