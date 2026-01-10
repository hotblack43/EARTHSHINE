PRO days_since_last_fullmoon,jd,days
jds=jd-30+findgen(30*36)/36.
mphase,jds,phases
gofindmaxima,jds,phases,days
return
end
