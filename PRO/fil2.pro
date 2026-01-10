From pth@dmi.dk Mon Mar  1 16:30:32 2010
Return-Path: <pth@dmi.dk>
Received: from fep25.mail.dk ([130.226.71.185]) by fep34.mail.dk (InterMail
 vM.7.09.02.02 201-2219-117-103-20090326) with ESMTP id
 <20100301153032.ZUEQ16429.fep34.mail.dk@fep25.mail.dk> for
 <thejll@mail.dk>; Mon, 1 Mar 2010 16:30:32 +0100
Received: from mailgw.dmi.dk ([130.226.71.185]) by fep25.mail.dk (InterMail
 vG.3.00.04.00 201-2196-133-20080908) with ESMTP id
 <20100301153032.ORMC23111.fep25.mail.dk@mailgw.dmi.dk> for
 <thejll@mail.dk>; Mon, 1 Mar 2010 16:30:32 +0100
Received: from localhost (localhost.dmi.dk [127.0.0.1]) by mailgw.dmi.dk
 (8.12.3/8.12.11/Debian-1) with ESMTP id o21FEG2U000369 for
 <thejll@mail.dk>; Mon, 1 Mar 2010 15:14:16 GMT
Received: from mailgw.dmi.dk ([127.0.0.1]) by localhost (mailgw.dmi.dk
 [127.0.0.1]) (amavisd-new, port 10024) with LMTP id 32118-02-2 for
 <thejll@mail.dk>; Mon, 1 Mar 2010 15:14:15 +0000 (GMT)
Received: from mailserver.dmi.dk (postoffice.dmi.dk [130.226.64.60]) by
 mailgw.dmi.dk (8.12.3/8.12.3/Debian-7.2) with ESMTP id o21FDFHE032734 for
 <thejll@mail.dk>; Mon, 1 Mar 2010 15:13:15 GMT
Received: from localhost (localhost.dmi.dk [127.0.0.1]) by
 mailserver.dmi.dk (Postfix) with ESMTP id BF3672B6F70 for <thejll@mail.dk>;
 Mon,  1 Mar 2010 15:13:15 +0000 (GMT)
Received: from mailserver.dmi.dk ([127.0.0.1]) by localhost
 (postoffice.dmi.dk [127.0.0.1]) (amavisd-new, port 10024) with LMTP id
 15076-01-50 for <thejll@mail.dk>; Mon, 1 Mar 2010 15:13:15 +0000 (GMT)
Received: from pandora.dmi.dk (egregious [130.226.67.115]) by
 mailserver.dmi.dk (Postfix) with ESMTP id AE1692B6F66 for <thejll@mail.dk>;
 Mon,  1 Mar 2010 15:13:15 +0000 (GMT)
Received: by pandora.dmi.dk (Postfix, from userid 1099) id A61984EDE8; Mon,
 1 Mar 2010 16:13:15 +0100 (CET)
To: thejll@mail.dk
Subject: files
Message-Id: <20100301151315.A61984EDE8@pandora.dmi.dk>
Date: Mon,  1 Mar 2010 16:13:15 +0100 (CET)
From: pth@dmi.dk (Peter Thejll)
X-Virus-Scanned: Debian amavisd-new at dmi.dk
X-Virus-Scanned: by amavisd-maia-1.0.0-rc5 (Debian) at dmi.dk
X-CM-Analysis: v=1.1 cv=x4l5IIzddOdcCTxRlIDdCFlHT+bXbyaqAaDtMn28a6o= c=1
 sm=0 a=K4R8LXkrXniH8spjYSGWBg==:17 a=pGqoYLK5hoovwdwC-l8A:9
 a=fT4fnI7zr_mVOh140qNfofjOtYgA:4 a=HpAAvcLHHh0Zw7uRqdWCyQ==:117
X-Evolution-Source: pop://120100934280@pop3.mail.dk/
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit

PRO evaluate_skill,y,x,skills,ab_estimated,ab_actual
 ; y is the target
 ; x is the reconstruction
 ; evaluates 6 skills
 skills=fltarr(6)
; plain correlation
 skills(0)=correlate(y,x)
; smoothed correlation 
 nsmoo=10
 skills(1)=correlate(smooth(y,nsmoo,/edge_truncate),smooth(x,nsmoo,/edge_truncate))
; bias between mean values of y
 skills(2)=(mean(x)-mean(y))/mean(y)
; bias between variance 
 sig_rec=stddev(smooth(x,nsmoo,/edge_truncate))
 sig_tar=stddev(smooth(y,nsmoo,/edge_truncate))
 skills(3)=(sig_rec-sig_tar)/sig_tar
; bias between linear slopes 
 dum=linfit(indgen(n_elements(y)),y,/double)
 tau_tar=dum(1)
 dum=linfit(indgen(n_elements(x)),x,/double)
 tau_rec=dum(1)
 skills(4)=(tau_rec-tau_tar)/tau_tar
; bias between regression coefficients 
; skills(5)=(ab_estimated(1)-ab_actual(1))/ab_actual(1)
 return
 end

